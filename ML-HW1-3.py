# LeetCode 1480. Running Sum of 1d Array
class Solution:
    def runningSum(self, nums: list[int]) -> list[int]:
        result = nums
        for i in range(1, len(result)):
            result[i] += result[i-1]
        return result
