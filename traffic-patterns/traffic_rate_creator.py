import math
import random
import argparse

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import time

"""
    Utility traffic pattern creation for testing purposes.
"""


def create_load_profile(all_profile_characteristics: dict):
    """
    This function takes as input the evaluation profile configuration and returns an actual load profile in numpy array
    form. Τhe profile configuration provides base load and top load possible values which are then chosen randomly. The
    profile is repeated as many times as the configuration suggests and the random selection is done again.
    Args:
        all_profile_characteristics (dict): Dictionary with profile configuration.

    Returns:
        np.array: n-column np.array with n being the number of load metrics
    """
    final_profile = pd.DataFrame()
    for load_name, profile_characteristics in sorted(all_profile_characteristics.items()):
        # For simple traffic profiles
        if 'default' in profile_characteristics:
            return np.random.choice(profile_characteristics['default'],
                                    profile_characteristics['number_of_steps']).reshape(-1, 1)

        profile = []
        if "repeat" in profile_characteristics:
            repeat = profile_characteristics['repeat']
        else:
            repeat = 1

        for _ in range(repeat):
            # Choose base load
            base_load = random.choice(profile_characteristics['base_load'])
            # Choose top load
            top_load = random.choice(profile_characteristics['top_load'])
            # Choose starting step of load rise
            start_of_rise = random.choice(profile_characteristics['start_of_rise'])
            # Choose ending step of load rise
            end_of_rise = random.choice(profile_characteristics['end_of_rise'])
            # Choose ending step of load fall
            end_of_downtrend = random.choice(profile_characteristics['end_of_downtrend'])
            # Populate only the start_of_rise, end_of_rise and end_of_downtrend steps and base load
            for step in range(profile_characteristics['number_of_steps']):
                if step <= start_of_rise:
                    profile.append(base_load)
                elif step < end_of_rise:
                    profile.append(None)
                elif step == end_of_rise:
                    profile.append(top_load)
                elif step < end_of_downtrend:
                    profile.append(None)
                else:
                    profile.append(base_load)

        profile = pd.Series(profile, dtype=np.float64, name="profile")
        # Interpolate the the values between max and min load
        profile = profile.interpolate(method="quadratic")
        # Add some noise
        s = np.random.normal(0, profile_characteristics['noise'],
                             profile_characteristics['number_of_steps'] * repeat)

        profile = profile + s
        # Remove values smaller than 0
        profile.loc[profile < 0] = 0
        final_profile[load_name] = profile

    final_profile.fillna(method="ffill", inplace=True)
    if final_profile.isnull().values.any():
        raise Exception("The traffic profile created has NAN values. Please fix. Traffic Profile: "
                        + str(final_profile.to_dict()))
    return final_profile.values


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--number_of_steps', help='The number of traffic steps (minimum: 4)')
    parser.add_argument('--low_load', help='The lowest traffic (link rate)')
    parser.add_argument('--high_load', help='The highest traffic (link rate)')
    parser.add_argument('--plot_file', help='The full path of the plot file')
    parser.add_argument('--traffic_pattern_file', help='The full path of the traffic pattern file')

    args = parser.parse_args()

    steps = int(args.number_of_steps) if args.number_of_steps is not None else 100

    if steps < 3:
        print("You should provide at least 4 traffic steps.")
        exit(1)

    profiles = {
        "load": {
            "number_of_steps": steps,
            "base_load": [
                float(args.low_load) if args.low_load is not None else 0.0,
            ],
            "top_load": [
                float(args.high_load) if args.high_load is not None else 100.0,
            ],
            "noise": 0.03,
            "repeat": 1
        },
    }
    profiles["load"].update({
        "start_of_rise": [
            int(math.floor(steps / 4))
        ],
        "end_of_rise": [
            2 * int(math.floor(steps / 3))
        ],
        "end_of_downtrend": [
            3 * int(math.floor(steps / 3))
        ],
    })

    new_profile = create_load_profile(profiles)
    plt.plot(new_profile)
    datetime_str = time.strftime("%Y%m%d-%H%M%S")
    plt.savefig(args.plot_file if args.plot_file is not None and args.plot_file != ""
                else f"./plot_traffic_pattern_{datetime_str}.png")
    fp = open(args.traffic_pattern_file if args.traffic_pattern_file is not None and args.traffic_pattern_file != ""
              else f"./traffic_pattern_{datetime_str}.txt", "w")
    for value in new_profile:
        fp.write(str(value[0]) + "\n")

    fp.close()
