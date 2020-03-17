package xue;

import java.util.Scanner;

public class OneCount {

    int oneCount(int idx, int[] arr, int speed, int time, boolean direct){
        if(time == 0){
            return arr[idx]==1 ? 1 : 0;
        }
        int cnt = arr[idx]==1 ? 1 : 0;   // 记录的上一次有没有经过1
        int start = 0;
        int end = arr.length-1;
        int target = direct?  idx + speed : idx - speed; // 正向为 true
        while (target > end || target < start) {  // 镜像
            if(target > end){
                target = 2*end - target;
                direct = !direct;
            }
            if (target < start) {
                target = 2*start - target;
                direct = !direct;
            }
        }

//        int cnt = arr[target]==1 ? 1 : 0;
        cnt += oneCount(target, arr, speed, time-1, direct);
        return cnt;
    }


    // 从idx开始走，边界是start和end
    int nextStep(int idx, int start, int end, int speed, boolean direct){
        int target = direct?  idx + speed : idx - speed; // 正向为 true
        while (target > end || target < start) {
            if(target > end){
                target = 2*end - target;
                direct = !direct;
            }
            if (target < start) {
                target = 2*start - target;
                direct = !direct;
            }
        }

        return target;
    }

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        int[] arr = {0, 1, 1, 0, 0};
        while(true){
            String params = in.nextLine();
            int speed = Integer.parseInt(params.split(" ")[0]);
            int time = Integer.parseInt(params.split(" ")[1]);

            int cnt = new OneCount().oneCount(2,arr, speed, time, true);
            System.out.println(cnt);
        }

    }
}
