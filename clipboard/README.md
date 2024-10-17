# Clipboard

To Follow the code, check the test and retrace from there. Also, please read @spec for a better understanding of the functions.

Context File:
  - @[Available_shifts.ex](https://github.com/akchaudhary6532/assignment-clipboard-health/blob/dev1/clipboard/lib/clipboard/context/available_shifts.ex)

Test Files: 
  - context (logic) tests 
    @ [available_shifts_test.exs](https://github.com/hatchways-community/1a2c5b5a56954f0d965ce5c5d1443009/blob/8b8dcb332a314175b946c3a062a6419a7894fa3b/clipboard/test/clipboard/context/available_shifts_test.exs)
   - controller (functional) test 
    @ [shift_controller_test.exs](https://github.com/hatchways-community/1a2c5b5a56954f0d965ce5c5d1443009/blob/8b8dcb332a314175b946c3a062a6419a7894fa3b/clipboard/test/clipboard_web/controllers/shift_controller_test.exs)

---

Ignored requirement:
- The shifts must be grouped by date. 
I couldn't understand what the resulting response would look like. was this a logical group? or SQL level group by? If a day has 5 available shifts, what would the SQL response look like in that case? -- hence ignored this for now.

Performance key points. (DATABASE)
The Data is evenly distributed, but I assume people are not interested in their past shifts. so we can still partition the shifts table and move older data to a warehouse. This will reduce the table size and hence the index size increasing the speed of DB.

Create Indexs, I created these indexes in my local DB.
```
create index shift_facility_id on "Shift"(facility_id);
create index shift_start on "Shift"("start");
create index shift_end on "Shift"("end");
create index shift_is_deleted on "Shift"("is_deleted");
create index shift_worker_id on "Shift"("worker_id");
create index shift_profession on "Shift"("profession");
create index facility_is_active on "Facility"("is_active");
create index document_worker_worker_id on "DocumentWorker"("worker_id");
```

Still, if the API requests are very large. SO let's start reading from replications as well with some load balancing.


Performance key points. (API)
- Use tools like Nginix to create API queues this will help serve more requests than physically possible by the machine at the cost of increased latency when the machine is at full capacity and rate limit as well.

- Create a cluster and use a load balancer.

- Use batch requests whenever possible.

Use observability tools like Grafana, and Prometheus to keep an eye on the performance, memory and CPU load trend and slow queries.



