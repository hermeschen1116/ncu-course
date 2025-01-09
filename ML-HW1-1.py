# LeetCode 1313. Decompress Run-Length Encoded List
class Solution:
    def decompressRLElist(self, nums: list[int]) -> list[int]:
        num_list = len(nums)
        result = []
        for i in range(0, num_list, 2):
            result.extend([nums[i + 1]] * nums[i])
        return result
