integrate with code commits and github
create files
debug files
create test cases
SSE processing to stream responses
add the ability to add src code by crawling the tree (use only necessary files; create a .crawlignore)
work across multiple repositories simultaneously
work with mulitple versions of this code simultaneously through github



# Example of an ideal prompt request:
Please modify the following function definitions into uvicorn api routes in a file under /app/api/data_collection.py
Then, update main.py to use these routes
Create tests
Evaluate Tests
Debug any errors as they arise
use train-of-thought (logging to __train_of_thought__.md to see what the model has been thinking and is currently doing)
send me a notification when the updates are complete through slack


# Bugs
 I do not need to create a tree when using -t if the __tree__.md is not empty
whenever i create a new conda env, i need to reinstall the requirements.txt; how do I surmount this problem?


 # Example prompt

 Please modify the following function definitions into uvicorn api routes in a file under /app/api/data_collection.py
Then, update main.py to use these routes
(base) linux-pc@pc:~/gh/projects/NeuralNexus/Avatar-Data-Collection-API$ ai -ctps
LLAMA 4 Terminal
Using code file: ./llama-4-structured.py
Using code file: ./app/main.py
Using system context file: /home/linux-pc/gh/projects/NeuralNexus/Avatar-Data-Collection-API/prompt/__system_context__.md
Using prompt context file: /home/linux-pc/gh/projects/NeuralNexus/Avatar-Data-Collection-API/prompt/__prompt__.md
[16:16:38] /home/linux-pc/gh/projects/NeuralNexus/Avatar-Data-Collection-API/prompt/__tree__.m llama4_terminal_client.py:156
           d                                                                                                                

Response:

### Step 1: Create a new file under /app/api/data_collection.py

First, let's create a new file `data_collection.py` under the `/app/api` directory.

### Step 2: Define API routes in data_collection.py

We'll define the API routes using FastAPI. For this example, let's assume we have two functions: `collect_data` and 
`process_data`. We'll convert these into API routes.

```python
# app/api/data_collection.py

from fastapi import APIRouter
from pydantic import BaseModel

# Define the API router
router = APIRouter(
    prefix="/data_collection",
    tags=["Data Collection"],
    responses={404: {"description": "Not found"}},
)

# Define a request body model for collect data
class CollectDataRequest(BaseModel):
    """Request body model for collecting data."""
    source: str
    params: dict

# Define a request body model for process data
class ProcessDataRequest(BaseModel):
    """Request body model for processing data."""
    data: list

@router.post("/collect")
async def collect_data(request: CollectDataRequest):
    """
    Collects data from a specified source.

    Args:
    - request (CollectDataRequest): The request body containing the source and parameters.

    Returns:
    - A dictionary with a message indicating the status of the data collection.
    """
    # Implement data collection logic here
    return {"message": "Data collection initiated"}

@router.post("/process")
async def process_data(request: ProcessDataRequest):
    """
    Processes the collected data.

    Args:
    - request (ProcessDataRequest): The request body containing the data to be processed.

    Returns:
    - A dictionary with a message indicating the status of the data processing.
    """
    # Implement data processing logic here
    return {"message": "Data processing initiated"}
```

### Step 3: Update main.py to use the new API routes

Now, let's update `main.py` to include the new API routes.

```python
# app/main.py

from fastapi import FastAPI
from app.api.data_collection import router as data_collection_router

# Create the FastAPI application
app = FastAPI(
    title="Data Collection API",
    description="API for data collection and processing",
    version="1.0.0",
)

# Include the data collection API router
app.include_router(data_collection_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Example Commit Message

```
Add API routes for data collection and processing

* Created a new file `data_collection.py` under `/app/api` with API routes for data collection and processing
* Updated `main.py` to include the new API routes
* Added documentation for the API routes and request body models
```

The code would then iteratively follow the steps defined, log what the model has done and is currently doing as the model is doing so (__train_of_thought__.md), create tests, test the new implementation, evaluate the results, log & analyze and debug any errors. Repeat until the final result is valid. Must know when the final result satifies the initial prompt requirements.