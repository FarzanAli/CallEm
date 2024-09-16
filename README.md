A barebones functionality demo:

https://github.com/user-attachments/assets/02a7bbd1-e156-4c31-b393-e73bed2b3d7e

This project has multiple components:
- The front end iOS application which interfaces with the call and provides a caller menu
- A seperate application ([Call-IVR](https://github.com/FarzanAli/Call-IVR)) which automates the process of calling several customer service lines and fetching their caller menu so that it is ready to go when a user needs to call
- A [NLP application](https://github.com/FarzanAli/parse-call) which assists [Call-IVR](https://github.com/FarzanAli/Call-IVR) by listening, understanding, and making menu selections in real-time to aid in traversing all menu selection paths.
