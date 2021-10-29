import asyncio
import logging

import aiohttp
import attr
from attr.validators import instance_of

# Code in: https://www.youtube.com/watch?v=jbdWXL-LwUE

LOGGER_FORMAT = '%(asctime)s %(message)s'
logging.basicConfig(format=LOGGER_FORMAT, datefmt='[%H:%M:%S]')
log = logging.getLogger()
log.setLevel(logging.INFO)

@attr.s
class Fetch:

    limit = attr.ib() #batch
    rate = attr.ib(default = 5, converter = int) #speed

    async def make_request(self, url):
        async with self.limit:
            async with aiohttp.ClientSession() as session:
                async with session.request(method = 'POST', url = url, data = '{"instances": [1.0, 2.0, 5.0]}') as response:
                #async with session.post(url,
                    json = await response.json()
                    status = response.status
                    log.info(f'Made request: {url}, Status: {status}')

                    await asyncio.sleep(self.rate)


async def make_requests(urls, rate, limit):
    limit = asyncio.Semaphore(limit)

    f = Fetch(
            rate = rate,
            limit = limit,
    )

    tasks = []

    for url in urls:
        tasks.append(f.make_request(url = url))

    results = await asyncio.gather(*tasks)


limit = 1000
urls = []
for i in range(0,limit):
    urls.append('http://localhost:8501/v1/models/half_plus_two:predict')

while True:
    asyncio.run(
            make_requests(
                urls = urls,
                rate = 1,
                limit = limit
            )
    )
