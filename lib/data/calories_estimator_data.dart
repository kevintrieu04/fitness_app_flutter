class CaloriesInfo {
  CaloriesInfo({
    this.caloriesPerSlice = -1,
    this.caloriesPerServing = -1,
    this.caloriesPerGram = -1,
  });

  double caloriesPerSlice;
  double caloriesPerServing;
  double caloriesPerGram;
}

final caloriesInfoList = {
  "Apple": CaloriesInfo(
    caloriesPerSlice: 57,
    caloriesPerServing: 93,
    caloriesPerGram: 1,
  ),
  "Fried Rice" : CaloriesInfo(
    caloriesPerServing: 520,
    caloriesPerGram: 2,
  ),
  "Lychee" : CaloriesInfo(
    caloriesPerServing: 6,
    caloriesPerGram: 1,
  ),
  "Noodle Soup" : CaloriesInfo(
    caloriesPerServing: 190,
    caloriesPerGram: 2,
  ),
  "Fried Chicken" : CaloriesInfo(
    caloriesPerServing: 294,
    caloriesPerGram: 3,
  ),
  "Watermelon" : CaloriesInfo(
    caloriesPerSlice: 86,
    caloriesPerServing: 919,
  ),
  "Grilled Meat Skewers" : CaloriesInfo(
    caloriesPerServing: 250,
    caloriesPerGram: 3,
  ),
  "Beef Noodle Soup" : CaloriesInfo(
    caloriesPerServing: 300,
    caloriesPerGram: 2,
  ),
  "Hot Pot" : CaloriesInfo(
    caloriesPerServing: 800,
  ),
  "Dumplings" : CaloriesInfo(
    caloriesPerSlice: 80,
    caloriesPerServing: 250,
  ),
  "Pizza" : CaloriesInfo(
    caloriesPerSlice: 272,
    caloriesPerServing: 2387,
    caloriesPerGram: 3,
  ),
  "Stir-fried Noodles": CaloriesInfo(
    caloriesPerServing: 170,
    caloriesPerGram: 2,
  ),
};
