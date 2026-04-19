---
name: tdd-python
description: Python specific test patterns, commands, fixtures, mocking, parametrization, and coverage. Always used together with `/test-driven-development` base skill.
---

# TDD — Python
> **Before proceeding, read `.config/opencode/test-driven-development/SKILL.md` first.**
> Read the base skill first for TDD philosophy and cycle.

---

## Commands

```bash
# Run a single test file
pytest path/to/test_file.py -v

# Run a single test
pytest path/to/test_file.py::TestClass::test_method -v

# Run full suite
pytest

# Watch mode during development
ptw                                      # pip install pytest-watch

# Coverage report
pytest --cov=src --cov-report=term-missing
pytest --cov=src --cov-fail-under=80

# Run until first failure
pytest -x

# Run only last failed tests
pytest --lf

# Run tests matching pattern
pytest -k "test_user"

# Skip slow tests
pytest -m "not slow"

# Drop into debugger on failure
pytest --pdb
```

---

## Coverage Config

`pyproject.toml`:
```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "--strict-markers",
    "--cov=src",
    "--cov-report=term-missing",
    "--cov-fail-under=80",
]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]

[tool.coverage.report]
fail_under = 80
show_missing = true
```

---

## Test Types

### Unit Test

```python
import pytest
from myapp.services import UserService

class TestUserService:
    @pytest.fixture(autouse=True)
    def setup(self):
        self.service = UserService()

    def test_create_user(self):
        user = self.service.create_user("Alice")
        assert user.name == "Alice"

    def test_delete_user(self):
        user = User(id=1, name="Bob")
        self.service.delete_user(user)
        assert not self.service.user_exists(1)
```

### Async Test

```python
import pytest

@pytest.mark.asyncio
async def test_retries_failed_operations_3_times():
    attempts = 0

    async def operation():
        nonlocal attempts
        attempts += 1
        if attempts < 3:
            raise ValueError("fail")
        return "success"

    result = await retry_operation(operation)

    assert result == "success"
    assert attempts == 3
```

### Integration Test (API)

```python
# FastAPI / Flask
@pytest.fixture
def client():
    app = create_app(testing=True)
    return app.test_client()

def test_returns_markets_successfully(client):
    response = client.get("/api/markets")
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert isinstance(data["data"], list)

def test_rejects_invalid_query_params(client):
    response = client.get("/api/markets?limit=invalid")
    assert response.status_code == 422
```

### Database Integration Test

```python
@pytest.fixture
def db_session():
    session = Session(bind=engine)
    session.begin_nested()
    yield session
    session.rollback()   # always rolls back — no test pollution
    session.close()

def test_create_user(db_session):
    user = User(name="Alice", email="alice@example.com")
    db_session.add(user)
    db_session.commit()

    retrieved = db_session.query(User).filter_by(name="Alice").first()
    assert retrieved.email == "alice@example.com"
```

---

## Fixtures

### Setup / Teardown

```python
@pytest.fixture
def database():
    db = Database(":memory:")
    db.create_tables()
    yield db          # test runs here
    db.close()        # teardown
```

### Fixture Scopes

```python
# function (default) — fresh for each test
@pytest.fixture
def temp_client(): ...

# module — shared within a test file
@pytest.fixture(scope="module")
def module_db(): ...

# session — shared for entire test run
@pytest.fixture(scope="session")
def shared_resource(): ...
```

### Autouse Fixture

```python
@pytest.fixture(autouse=True)
def reset_config():
    Config.reset()
    yield
    Config.cleanup()
# Runs automatically before/after every test — no need to declare it
```

### Shared Fixtures via conftest.py

```python
# tests/conftest.py
@pytest.fixture
def client():
    app = create_app(testing=True)
    with app.test_client() as client:
        yield client

@pytest.fixture
def auth_headers(client):
    response = client.post("/api/login", json={"username": "test", "password": "test"})
    token = response.json["token"]
    return {"Authorization": f"Bearer {token}"}
```

### Temp Files

```python
def test_with_tmp_path(tmp_path):
    test_file = tmp_path / "test.txt"
    test_file.write_text("hello world")
    result = process_file(str(test_file))
    assert result == "hello world"
    # tmp_path is cleaned up automatically
```

---

## Parametrization

```python
@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (0, 0, 0),
    (-1, 1, 0),
])
def test_add(a, b, expected):
    assert add(a, b) == expected
```

With readable IDs:
```python
@pytest.mark.parametrize("input,expected", [
    ("valid@email.com", True),
    ("invalid", False),
    ("@no-domain.com", False),
], ids=["valid-email", "missing-at", "missing-domain"])
def test_email_validation(input, expected):
    assert is_valid_email(input) is expected
```

---

## Mocking

### Patch a Function

```python
from unittest.mock import patch, Mock

@patch("myapp.external_api_call")
def test_with_mock(api_call_mock):
    api_call_mock.return_value = {"status": "success"}
    result = my_function()
    api_call_mock.assert_called_once()
    assert result["status"] == "success"
```

### Patch with Side Effects

```python
@patch("myapp.api_call")
def test_api_error_handling(api_call_mock):
    api_call_mock.side_effect = ConnectionError("Network error")
    with pytest.raises(ConnectionError):
        api_call()
```

### Patch with monkeypatch (pytest-native)

```python
def test_handles_database_error(monkeypatch):
    def mock_db_error():
        raise Exception("DB connection failed")

    monkeypatch.setattr("myapp.db.get_markets", mock_db_error)
    response = client.get("/api/markets")
    assert response.status_code == 500
```

### Mock via Fixtures

```python
@pytest.fixture
def mock_openai(monkeypatch):
    from unittest.mock import AsyncMock
    async_mock = AsyncMock(return_value=[0.1] * 1536)
    monkeypatch.setattr("myapp.ai.generate_embedding", async_mock)
    return async_mock

def test_semantic_search_uses_embedding(mock_openai):
    search_markets("election")
    mock_openai.assert_called_once_with("election")
```

### Mock Context Manager

```python
from unittest.mock import mock_open, patch

@patch("builtins.open", new_callable=mock_open)
def test_file_reading(mock_file):
    mock_file.return_value.read.return_value = "file content"
    result = read_file("test.txt")
    mock_file.assert_called_once_with("test.txt", "r")
    assert result == "file content"
```

### Autospec (catches API misuse)

```python
@patch("myapp.DBConnection", autospec=True)
def test_autospec(db_mock):
    db = db_mock.return_value
    db.query("SELECT * FROM users")
    # Will fail if DBConnection.query doesn't exist
    db_mock.assert_called_once()
```

---

## Exception Testing

```python
# Basic
with pytest.raises(ZeroDivisionError):
    divide(10, 0)

# Match message
with pytest.raises(ValueError, match="invalid input"):
    validate_input("bad")

# Inspect exception attributes
with pytest.raises(CustomError) as exc_info:
    raise CustomError("error", code=400)
assert exc_info.value.code == 400
```

---

## Markers

```python
@pytest.mark.slow
def test_slow_operation(): ...

@pytest.mark.integration
def test_api_integration(): ...
```

```bash
pytest -m "not slow"
pytest -m integration
pytest -m "unit and not slow"
```

---

## Anti-Patterns

**Don't test implementation details:**
```python
# ❌ Internal state
assert service._cache == {"key": "value"}

# ✅ Observable behavior
assert service.get("key") == "value"
```

**Don't share state between tests:**
```python
# ❌
class TestUser:
    user = None
    def test_creates_user(self): TestUser.user = create_user(...)
    def test_updates_user(self): TestUser.user.update(...)  # depends on above

# ✅
class TestUser:
    def test_creates_user(self):
        user = create_user("alice@example.com")
        assert user.email == "alice@example.com"

    def test_updates_user(self):
        user = create_user("alice@example.com")
        user.update(name="Alice")
        assert user.name == "Alice"
```

**Don't swallow exceptions in tests:**
```python
# ❌
try:
    result = risky_function()
    assert result is not None
except:
    pass

# ✅
with pytest.raises(ValueError, match="invalid input"):
    risky_function(invalid_arg)
```

---

## File Organization

```
src/
└── myapp/
    ├── api/markets.py
    └── services/search.py
tests/
├── conftest.py               # Shared fixtures
├── unit/
│   ├── test_search.py
│   └── test_utils.py
├── integration/
│   └── test_markets_api.py
└── e2e/
    └── test_user_flows.py
```

---

## CI/CD

```yaml
# GitHub Actions
- name: Run Tests
  run: pytest --cov=src --cov-report=xml --cov-fail-under=80

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    file: ./coverage.xml
```
