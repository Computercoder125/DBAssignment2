
// Import the dataset
// Run this manually in the shell:
// mongoimport --db test --collection unemployment --type csv --headerline --file "path/to/unemployment.csv"

// Query 1: Over how many years was the unemployment data collected?
db.unemployment.distinct("Year").length;

// Query 2: How many states were reported on in this dataset?
db.unemployment.distinct("State").length;

// Query 3: What does this query compute?
// db.unemployment.find({Rate: {$lt: 1.0}}).count();
// Explanation: Counts the number of records where the unemployment rate is less than 1%.

// Query 4: Find all states with unemployment rate higher than 10%.
db.unemployment.aggregate([
  { $match: { Rate: { $gt: 10 } } },
  { $group: { _id: "$State" } }
]);

// Query 5: Calculate the average unemployment rate across all states.
db.unemployment.aggregate([
  { $group: { _id: null, avgRate: { $avg: "$Rate" } } }
]);

// Query 6: Find all states with an unemployment rate between 5% and 8%.
db.unemployment.aggregate([
  { $match: { Rate: { $gte: 5, $lte: 8 } } },
  { $group: { _id: "$State" } }
]);

// Query 7: Find the state with the highest unemployment rate.
db.unemployment.aggregate([
  { $sort: { Rate: -1 } },
  { $limit: 1 },
  { $project: { _id: 0, State: 1, Rate: 1 } }
]);

// Query 8: Count how many states have an unemployment rate above 5%.
db.unemployment.aggregate([
  { $match: { Rate: { $gt: 5 } } },
  { $group: { _id: "$State" } },
  { $count: "statesAbove5Percent" }
]);

// Query 9: Calculate the average unemployment rate per state by year.
db.unemployment.aggregate([
  {
    $group: {
      _id: { State: "$State", Year: "$Year" },
      avgRate: { $avg: "$Rate" }
    }
  },
  { $sort: { "_id.State": 1, "_id.Year": 1 } }
]);

// Query 10 (Extra Credit): Calculate the total unemployment rate across all counties for each state.
db.unemployment.aggregate([
  {
    $group: {
      _id: "$State",
      totalRate: { $sum: "$Rate" }
    }
  },
  { $sort: { totalRate: -1 } }
]);

// Query 11 (Extra Credit): The same as Query 10 but for states with data from 2015 onward.
db.unemployment.aggregate([
  { $match: { Year: { $gte: 2015 } } },
  {
    $group: {
      _id: "$State",
      totalRate: { $sum: "$Rate" }
    }
  },
  { $sort: { totalRate: -1 } }
]);
