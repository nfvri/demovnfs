import os
import tensorflow as tf
import json

def setup_input_images(batch_size=32):
    _URL = 'https://storage.googleapis.com/mledu-datasets/cats_and_dogs_filtered.zip'
    path_to_zip = tf.keras.utils.get_file('cats_and_dogs.zip', origin=_URL, extract=True)
    PATH = os.path.join(os.path.dirname(path_to_zip), 'cats_and_dogs_filtered')

    validation_dir = os.path.join(PATH, 'validation')

    IMG_SIZE = (160, 160)

    validation_dataset = tf.keras.utils.image_dataset_from_directory(validation_dir,
                                                                     shuffle=False,
                                                                     batch_size=batch_size,
                                                                     image_size=IMG_SIZE)

    AUTOTUNE = tf.data.AUTOTUNE
    validation_dataset = validation_dataset.prefetch(buffer_size=AUTOTUNE)

    val_batch = validation_dataset.take(1)


    for batch, label in val_batch.as_numpy_iterator():
        print(label)

    return batch

def prepare_inputs(image):
    data = json.dumps({
        "instances": image.tolist()
    })
    print(data)

    headers = {"content-type": "application/json"}
    return data




batch = setup_input_images(batch_size=32)

for index in range(batch.shape[0]):
    image = batch[index]
    print(prepare_inputs(image))


