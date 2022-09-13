-- source : https://www.mavenanalytics.io/data-playground
use sqlproject2;
select * from passenger_satisfaction
limit 20;


-- Which percentage of airline passengers are satisfied? 
select (count(*)/(select count(*) from passenger_satisfaction))*100 satisfied_passenger_count_percentage
from passenger_satisfaction
where satisfaction = 'Satisfied'; -- Overall 43% passengers have rated 'Satisfied'

-- Does percentage of airline passengers that are satisfied vary by customer type? 
select customer_type,(count(*)/(select count(*) from passenger_satisfaction))*100 satisfied_passenger_count_percentage
from passenger_satisfaction
where satisfaction = 'Satisfied'
group by 1; -- 39% of satisfied passengers are repeating passengers

-- Does percentage of airline passengers that are satisfied vary by type of travel? 
select type_of_travel,(count(*)/(select count(*) from passenger_satisfaction))*100 satisfied_passenger_count_percentage
from passenger_satisfaction
where satisfaction = 'Satisfied'
group by 1; -- 40% of satisfied passengers travel for Business

-- What is the customer profile for a repeating airline passenger?
select type_of_travel,gender, floor(avg(age)) avg_age, count(*) count_of_passengers
from passenger_satisfaction
where customer_type = 'Returning'
Group by 1,2
order by 4 desc; -- The repeating passengers are mostly male passengers (average age of 43) traveling with some Business purpose 

-- Does flight distance affect customer preferences or flight patterns?
select class, case when range_dist = 1 then 'short' when range_dist = 2 then 'medium' else 'long' end as flight_distance,
count(range_dist) passenger_preference from (
	select *, ntile(3) over (order by flight_distance) as range_dist
	from passenger_satisfaction) t1
group by 1,2
order by 2,3 desc; -- as distance increases passengers prefer Business class otherwise Economy class is preferred

select case when range_dist = 1 then 'short' when range_dist = 2 then 'medium' else 'long' end as flight_distance,
avg(arrival_delay) arrival_delay, avg(departure_delay) departure_delay  from (
	select *, ntile(3) over (order by flight_distance) as range_dist
	from passenger_satisfaction) t1
group by 1
order by 1; -- arrival and departure delays are observed more in medium haul flights 

-- Ratings for different services
select round(avg(Departure_Arrival_Time_Convenience),2) Departure_Arrival_Time_Convenience,
round(avg(Online_Booking),2) Online_Booking,
round(avg(Checkin_Service),2) Checkin_Service,round(avg(Online_Boarding),2) Online_Boarding,
round(avg(Gate_Location),2) Gate_Location,round(avg(Onboard_Service),2) Onboard_Service,
round(avg(Seat_Comfort),2) Seat_Comfort,
round(avg(Leg_Room_Service),2) Leg_Room_Service, round(avg(Cleanliness),2) Cleanliness,
round(avg(Food_and_Drink),2) Food_and_Drink,
round(avg(Inflight_Service),2) Inflight_Service,round(avg(Inflight_Wifi_Service),2) Inflight_Wifi_Service,
round(avg(Inflight_Entertainment),2) Inflight_Entertainment,
round(avg(Baggage_Handling),2) Baggage_Handling
from passenger_satisfaction; -- passengers have rated highest for 'Baggage Handing service' and 'In flight services'; rated least for 'In flight WiFi services'




