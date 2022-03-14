# Elixir challenge

## Description

#### Introduction
In this test you need to create a web API. Tech Stack Elixir, Phoenix and PostgreSQL.

#### What you need to do

##### Import seed data

Implement code to import the CSV data provided below:


```
CSV
1 id,parent_id,item_name,priority
2 1,nil,heading 1,3
3 2,nil,heading 2,1
4 3,1,folder 1 1,4
5 4,1,folder 1 2,2
6 5,2,folder 2 1,2
7 6,2,folder 2 2,3
8 7,2,folder 2 3,5
9 8,6,subfolder 2 2 1,2
10 9,7,subfolder 2 3 1,1
11 10,7,subfolder 2 3 2,5
```

##### API Implementation

 - Expose the imported data via a single HTTP endpoint that will return all the rows. Add
an additional attribute named path_name that should follow the format: for a folder
with id 10 it should be heading 2/folder 2 3/subfolder 2 3 2 .
- Allow filtering items by item_name .
- Allow sorting items by priority .
- Allow paginating the response.
- Cover the code with tests.

## Solution

### Process

At the first step to build this project I created a [board](https://trello.com/b/XuRBKDXV/prodeal-elixir) en Trello where 
I managed all the tasks needed to accomplish this challenge.

There I tried to reflect my implementation process by adding some columns which represent the different steps of the process.
Due to obvious reasons, when you see the board all the cards are marked as Done but during the implementation process they were moving between different states.

Also, I added some labels to describe the nature of each ticket, for this project I only use 4 different labels.

- Development
- Documentation
- Spike
- Environment setup

**NOTE:** 
- Please note that the format of the user stories is not strictly what Kanban or Scrum suggest. I took my own format to reflect the work to be done.
- Not all the columns applies for the project since it is a non realistic environment where for example QA, To be refined, etc make no sense since only one person develop this test.

### Technical

The solution is implemented using Elixir/Phoenix/PostgreSQL as the tech stack.

#### Push strategy

I decided to push the code using PR's and I left them all open expecting to favor the feedback from your side. Please note that in a real project it is not practical to
have multiples PR on chain since one little change in one of them will force to rebase all the subsequents (and as a consequence force pushed them, fact that I not recommend since it brakes commits history)

Regarding to the way in which I committed my code, I always tried to make small commits (self contained) and reflect the development process through the sequence of commits.
IMHO, developing thinking in the reviewer usually favor the review saving time and increasing the quality of the code delivered.

#### Run the project

To be able to run the project you will need to follow the steps listed below:

**Clone the repository**
```
git clone path_to_the_repository
```

**Get dependencies**
```
mix deps.get
```

**Build the database**
```
mix ecto.create
mix ecto migrate
```
**Seed the database**
```
mix mix run priv/repo/seeds.exs
```

#### API Documentation

The API has only one endpoint to list folders.

The endpoint gives the possibility of filter, sort and filter and sort. It also uses pagination to limit the quantity of records delivered.

The general route is  ```api/folders```

##### Filtering by item_name

To filter results the user has to privide the param called ```item_name``` and the value for the search.

```
Example:

GET api/folders?item_name=child

Will filter the results delivering only those fiolders which name is 'child'
```

##### Sorting by priority

To sort results the user has to privide the param called ```sort_by``` and the value ```priority```.

Also, the user can specify the order_method (:desc or :asc) by providing an extra param called ```order_by```.
If no order_method is provided the system will assume :desc to deliver the results

```
Example:

GET api/folders?sort_by=priority

Will sort the results.
```

##### Filtering and Sorting

The endpoint also gives the possibility to filer and sort at the same time. To do so the user only needs to call the endpoint 
using the params named above together.

```
Example:

GET api/folders?sort_by=priority&item_name=child

Will filter and sort the results.
```

##### Pagination

The endpoint supports pagination by limiting the results delivered.

By default the page limit is 2 records but this can by changed by providing a param called ```per_page```.
It also accepts other param called ```page``` to specify which page should be delivered. (By default will be 1).

The JSON response includes pagination data.

```
"pagination_data": {
   "next_page": ,
   "per_page": ,
   "prev_page": ,
   "total_pages":
 }
```

```
Example:

GET api/folders?page=3%per_page=3

Will returns page 3 with 3 records
```

**NOTE:** More documentation can be found in the collection that I created in Postman to test my solution. (I sent invite)

#### Testing

I added unit tests for the context where all the logic is located. Also, I added some test for the controller.

The testing solution can be improved for example mocking data instead of create records each time. Also, for the controller the calls to the context can be mocked to test only the controller logic.
Although, some integration tests are always helpful.

##### Postman

I created a collection in Postman where some examples can be found in order to test the endpoint. Also each request has a short description (as the documentation)
An environment called local will deliver the BASE_URL params used in the request. This variable has the value of ```localhost:4000```.

