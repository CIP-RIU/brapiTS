#Testing 

Discussion at PAG 2017 (Jan 19, 2017).

* Each database to implement test servers with test fixture
* test scripts need to consider calls calls to determine what is implemented (partial implementations can still be valid)
* TO DO: create JSON files with inputs and expected outputs for every call (one file per call, can contain several url/responses)
    * a list of [ { ‘url’: , ‘postdata’: , ‘response’: }, … ]
    * will be available from this repo.
* Testing implementation considerations
    * database ids cannot be relied upon and should not be tested against
    * use searches to identify appropriate objects and corresponding database identifiers (to be used in subsequent tests)
    * problem: how do you map the list of urls containing db ids to actual db ids in the database
      * use placeholders <> for ids that need to be discovered
    * authentication in testing will be addressed at the next hackathon.    

