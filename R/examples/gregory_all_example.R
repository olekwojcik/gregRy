#create plot data
planet_plot_data <- data.frame(plot_number = 1:20,
                               planet = c(rep("Kashyyyk", 5),
                                          rep("Forest Moon of Endor", 5),
                                          rep("Dagobah", 5),
                                          rep("Naboo", 5)),
                               count_of_trees = c(204, 156, 240, 286, 263,
                                                  112, 167, 131, 25, 145,
                                                  141, 65, 127, 15, 98,
                                                  100, 12, 49, 94, 69),
                               forest_cover = c(85, 74, 89, 95, 92,
                                                70, 73, 69, 11, 68,
                                                67, 30, 62, 15, 42,
                                                59, 5, 17, 25, 22),
                               eco_province = c("forest", "swamp", "forest", "forest", "forest",
                                                "forest", "forest", "forest", "grassland", "forest",
                                                "forest", "swamp", "swamp", "grassland", "swamp",
                                                "forest", "grassland", "grassland", "swamp", "swamp"))

#create mean data
planet_means <- data.frame(planet = c("Kashyyyk",
                                      "Forest Moon of Endor",
                                      "Dagobah",
                                      "Naboo"),
                           forest_cover = c(95,
                                            85,
                                            50,
                                            30))
#create proportion data
planet_province_prop <- data.frame(planet = c(rep("Kashyyyk", 2),
                                              rep("Forest Moon of Endor", 2),
                                              rep("Dagobah", 3),
                                              rep("Naboo", 3)),
                                   eco_province = c("forest", "swamp",
                                                    "forest", "grassland",
                                                    "forest", "grassland", "swamp",
                                                    "forest", "grassland", "swamp"),
                                   prop = c(0.8, 0.2,
                                            0.75, 0.25,
                                            0.1, 0.1, 0.8,
                                            0.2, 0.4, 0.4))

x1 <- gregory_all(plot_df = planet_plot_data,
                  resolution = "eco_province",
                  estimation = "planet",
                  pixel_estimation_means = planet_means,
                  proportions = planet_province_prop,
                  formula = count_of_trees ~ forest_cover,
                  prop = "prop")
x1