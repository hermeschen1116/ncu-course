import random

import numpy as np
import matplotlib.pyplot as plt


def is_in_circle(point: tuple) -> bool:
	return (pow(point[0], 2) + pow(point[1], 2)) < 1


def calculate_pi(number_of_points: int) -> float:
	points: list = [(random.uniform(-1, 1), random.uniform(-1, 1)) for _ in range(number_of_points)]
	points_in_circle: int = len([p for p in points if is_in_circle(p)])

	return ((points_in_circle * 1.0) / number_of_points) * 4


pow_l: int = 2
pow_h: int = 5
total_points: list = [pow(10, i) for i in range(pow_l, (pow_h + 1))]
possible_pi: list = [calculate_pi(p) for p in total_points]

plt.plot(total_points, possible_pi, 'g')
plt.title('approximate_pi')
plt.xlabel('total_points')
plt.ylabel('pi')
plt.xscale('log')
plt.show()
