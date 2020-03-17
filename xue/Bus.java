package xue;

// 景区开设接驳巴士，巴士按小景点的顺序接送游客，在五一、十一等旅游黄金周，每个小景点都有游客等待成巴士离开景区，景区调度中心派出一辆巴士，
// 要求巴士不停靠连续的小景点，停靠一个小景点后，该小景点等待的游客都要上巴士，景区调度中心需要计算这辆巴士停靠哪些小景点，可以带最多的乘客离开景区，
// 假设该辆巴士可以乘坐的游客没有上限。
// 例如：有6个小景点，顺序固定，每个景点等待的人依次是：20,2,16,18,1,10，这辆巴士最多接送48人
// leetcode 198  打家劫舍
public class Bus {

    // dp[i] 代表 nums[0...i] 的不相邻数组的最大值
    // dp[i] = max{ dp[i-1], dp[i-2]+nums[i] }
    int maxPeople(int[] nums) {
        if (nums == null || nums.length==0) {
            return 0;
        }
        if (nums.length == 1) {
            return nums[0];
        }
        int[] dp = new int[nums.length];
        dp[0] = nums[0];
        dp[1] = Math.max(nums[0], nums[1]);
        for (int i = 2; i < nums.length; i++) {
            dp[i] = Math.max(dp[i-1], dp[i-2]+nums[i]);
        }
        return dp[nums.length - 1];
    }

    public static void main(String[] args) {
        int[] nums = {20, 2, 16, 18, 1, 10};
        int max = new Bus().maxPeople(nums);
        System.out.println(max);
    }
}
