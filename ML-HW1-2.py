# LeetCode 1431. Kids With the Greatest Number of Candies
class Solution:
    def kidsWithCandies(self, candies: list[int], extraCandies: int) -> list[bool]:
        return [True if candy + extraCandies >= max(candies) else False for candy in candies]
