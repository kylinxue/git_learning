package xue;

// LeetCode456  132模式
public class Find132Pattern {
    public boolean find132pattern(int[] nums) {
        if(nums.length<3)
            return false;
        for (int i = 0; i < nums.length - 1; i++) {
            int max = Integer.MIN_VALUE;
            for (int j = i+1; j < nums.length; j++) {
                if(nums[j]>max)
                    max = nums[j];
                if(nums[j]<max && nums[i]<max && nums[i]<nums[j])
                    return true;
            }
        }
        return false;
    }

    public static void main(String[] args) {
        Find132Pattern f = new Find132Pattern();
        System.out.println(f.find132pattern(new int[]{1,2,3,4}));
        System.out.println(f.find132pattern(new int[]{1,5,3,4}));
    }
}
