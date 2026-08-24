# User Storie
1. As counter staff, I want to record the customer's name and phone number when they drop off a bike, so that I can contact them when the repair is ready or needs approval on a quote.

2. As counter staff, I want to record the bike's serial number and model, so that I hand back the correct bike after the repair.

3. As counter staff, I want to take a picture of the bike when it arrives, so that we have proof if a dispute happens.

4. As a mechanic, I want to write down what's wrong with the bike in a way that's accessible to other mechanics, so that I don't need to ask another mechanic what is wrong with the bike.

5. As a mechanic, I want to mark that a repair is waiting on the customer's response, so that I avoid doing work the customer hasn't agreed to.

6. As a mechanic, I want to add the jobs the repair needs from the price list, so that the quote and the final price match what was really done.

7. As a mechanic, I want to charge less than the list price sometimes, so that I can give a discount to a regular customer or when the job was easier than expected.

8. As a customer, I want to know the price of a repair before it starts, so that I can decide if I say yes or no.

9. As a customer, I want to say no to a repair and pick up my bike the way it arrived, so that I don't pay for work I didn't approve.

10. As counter staff, I want to search a repair by the customer's phone number and see its status, so that I can tell them if the bike is ready without walking to the back.

**Story 10 was too big — it bundled "see the status" with "see if it's late," which are two different things a person can use on their own. Split into 10a and 10b below:**

10a. As counter staff, I want to search a repair by phone number and see its current status, so that I can answer "is it ready" on the spot. *(split from story 10)*

10b. As counter staff, I want to see if a repair is late compared to the promised day, so that I can warn the customer before they call angry. *(split from story 10)*

11. As the owner, I want to see every repair that is late, so that I can call the customer before they call me.

12. As a customer, I want to see the repair history of a bike I own, so that I know what was done to it even if I bought it used from someone else.

13. As the owner, I want the price list to change every January without changing old invoices, so that a repair from last year still shows the price the customer paid back then.

14. As a website visitor, I want to see the price list on the website, so that I don't have to call just to ask how much a tune-up costs.


## Acceptance Criteria

Four stories, each with at least three acceptance criteria — conditions that are either true or false once you look at the finished screen.

### Story 1 — record customer name and phone at drop-off

- A repair cannot be saved without a customer name and a phone number.
- If the phone number already exists for a customer, that customer is reused instead of creating a duplicate.
- The bike being dropped off is linked to that customer as its current owner.

### Story 6 — mechanic adds jobs from the price list

- Only jobs that exist on the current price list can be added to a repair.
- Each job added shows the price it had at the moment it was added, not whatever the price list says later.
- A single repair can have more than one job attached to it.

### Story 10a — counter staff looks up a repair's status

- Searching by phone number returns every active repair tied to that customer.
- The status shown is always one of: dropped off, diagnosing, awaiting approval, in progress, ready, or picked up.
- If the phone number matches no repair, the screen says so instead of showing an empty result with no explanation.

### Story 11 — owner sees overdue repairs

- A repair appears on this screen only if today is past its promised date and it hasn't been picked up yet.
- Each entry shows the customer's name, phone number, and how many days overdue it is.
- **If no repair is currently overdue, the screen clearly says so instead of showing an empty list.**