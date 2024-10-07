-- task 1
SELECT aircraft_code, fare_conditions, COUNT(seat_no) AS seat_count 
FROM bookings.seats
GROUP BY aircraft_code, fare_conditions
ORDER BY aircraft_code, fare_conditions;

-- task 2
SELECT bookings.aircrafts_data.model, COUNT(bookings.seats.seat_no) AS seat_count 
FROM bookings.seats INNER JOIN bookings.aircrafts_data ON bookings.seats.aircraft_code = bookings.aircrafts_data.aircraft_code 
GROUP BY bookings.aircrafts_data.model;

-- task 3
SELECT bookings.flights.flight_id, bookings.flights.flight_no, bookings.flights.status, (bookings.flights.actual_departure - bookings.flights.scheduled_departure) AS flight_delay 
FROM bookings.flights
WHERE (bookings.flights.actual_departure - bookings.flights.scheduled_departure) > INTERVAL '2 hours' or (bookings.now() - bookings.flights.scheduled_departure) > INTERVAL '2 hours';

-- task 4
SELECT bookings.ticket_flights.ticket_no, bookings.tickets.passenger_name, bookings.tickets.contact_data, bookings.bookings.book_date
FROM bookings.ticket_flights
INNER JOIN bookings.tickets ON bookings.ticket_flights.ticket_no = bookings.tickets.ticket_no
INNER JOIN bookings.bookings ON bookings.tickets.book_ref = bookings.bookings.book_ref
WHERE bookings.ticket_flights.fare_conditions = 'Business'
ORDER BY bookings.bookings.book_date DESC LIMIT 10

-- task 5
SELECT bookings.flights.flight_id, bookings.flights.flight_no
FROM bookings.flights 
INNER JOIN bookings.ticket_flights ON bookings.flights.flight_id = bookings.ticket_flights.flight_id
WHERE bookings.ticket_flights.fare_conditions NOT LIKE 'Business'
GROUP BY bookings.flights.flight_id
ORDER BY bookings.flights.flight_id ASC

-- task 6
SELECT bookings.airports.airport_name, bookings.airports.city
FROM bookings.airports
INNER JOIN bookings.flights ON bookings.airports.airport_code = bookings.flights.departure_airport
WHERE bookings.flights.status LIKE 'Delayed';

-- task 7
SELECT bookings.airports.airport_name, COUNT(bookings.flights.flight_id) AS flight_count
FROM bookings.airports
INNER JOIN bookings.flights ON bookings.airports.airport_code = bookings.flights.departure_airport
GROUP BY bookings.airports.airport_name
ORDER BY flight_count DESC

-- task 8
SELECT bookings.flights.flight_id, bookings.flights.flight_no, bookings.flights.scheduled_arrival, bookings.flights.actual_arrival
FROM bookings.flights
WHERE bookings.flights.scheduled_arrival != bookings.flights.actual_arrival

-- task 9
SELECT bookings.seats.aircraft_code, bookings.aircrafts_data.model, bookings.seats.seat_no, bookings.seats.fare_conditions
FROM bookings.seats
INNER JOIN bookings.aircrafts_data ON bookings.seats.aircraft_code = bookings.aircrafts_data.aircraft_code
WHERE bookings.seats.aircraft_code LIKE '321' and bookings.seats.fare_conditions NOT LIKE 'Economy'

-- task 10
SELECT bookings.airports_data.airport_code, bookings.airports_data.airport_name, bookings.airports_data.city
FROM bookings.airports_data
WHERE bookings.airports_data.city IN (
	SELECT bookings.airports_data.city
	FROM bookings.airports_data
	GROUP BY bookings.airports_data.city
	HAVING COUNT(*) > 1
)

-- task 11
WITH AverageCost AS (
    SELECT AVG(bookings.bookings.total_amount) AS avg_price
    FROM bookings.bookings
),
PassengerTotals AS (
    SELECT bookings.tickets.passenger_id, bookings.tickets.passenger_name, SUM(bookings.bookings.total_amount) AS total_cost
    FROM bookings.tickets
	JOIN bookings.bookings ON bookings.tickets.book_ref = bookings.bookings.book_ref
    GROUP BY bookings.tickets.passenger_id, bookings.tickets.passenger_name
)
SELECT bookings.tickets.passenger_id, bookings.tickets.passenger_name
FROM PassengerTotals pt
	JOIN AverageCost ac ON pt.total_cost > ac.avg_price;

-- task 12
SELECT *
FROM bookings.flights
WHERE bookings.flights.status LIKE 'Scheduled' OR 
	  bookings.flights.status LIKE 'On Time' OR 
	  bookings.flights.status LIKE 'Delayed' AND 
      bookings.flights.departure_airport = 'SVX' AND
      bookings.flights.arrival_airport LIKE 'SVO' AND
      scheduled_departure > NOW() + INTERVAL '2 hours'
ORDER BY scheduled_departure
LIMIT 1;

-- task 13
SELECT 'low_cost' AS ticket_type, ticket_no, amount AS ticket_price
FROM bookings.ticket_flights
ORDER BY amount ASC
LIMIT 1
UNION
SELECT 'high_cost' AS ticket_type, ticket_no, amount AS ticket_price
FROM bookings.ticket_flights
ORDER BY amount DESC
LIMIT 1;

-- task 14
CREATE TABLE Customers (
                           id SERIAL PRIMARY KEY,
                           firstName VARCHAR(50) NOT NULL,
                           lastName VARCHAR(50) NOT NULL,
                           email VARCHAR(100) UNIQUE NOT NULL,
                           phone VARCHAR(15)
);

-- task 15
CREATE TABLE Orders (
                        id SERIAL PRIMARY KEY,
                        customerId INT NOT NULL,
                        quantity INT NOT NULL CHECK (quantity > 0),
                        FOREIGN KEY (customerId) REFERENCES Customers(id)
                            ON DELETE CASCADE
);

-- task 16
INSERT INTO Customers (firstName, lastName, email, phone) VALUES
                                                              ('Тест', 'Тестович', 'test.testov@test.com', '89123456789'),
                                                              ('Август', 'Авдотьев', 'a.avd@test.com', '89123456789'),
                                                              ('Акакий', 'Акакьевич', 'akak.akak@test.com', '89123456789'),
                                                              ('Евфросинья', 'Петровна', 'tooOld.forEmail@test.com', '89123456789'),
                                                              ('Павел', 'Дуров', 'pavel.not.bald@test.com', '89123456789');

INSERT INTO Orders (customerId, quantity) VALUES
                                              (1, 6),
                                              (2, 3),
                                              (5, 9),
                                              (4, 2),
                                              (3, 1);

-- task 17
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
