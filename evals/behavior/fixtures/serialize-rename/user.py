from dataclasses import dataclass


@dataclass
class User:
    user_id: int
    name: str


def serialize(user):
    return {"userId": user.user_id, "name": user.name}
