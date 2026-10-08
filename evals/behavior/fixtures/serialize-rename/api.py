import json

from user import User, serialize


def get_user_response(user_id):
    return json.dumps(serialize(User(user_id=user_id, name="Ada")))
