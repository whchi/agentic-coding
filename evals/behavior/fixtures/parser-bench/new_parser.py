from functools import lru_cache
import json


@lru_cache(maxsize=1024)
def _parse(text):
    return json.loads(text)


def parse(text):
    return _parse(text)
