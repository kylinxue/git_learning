package xue;

// 最长公共子序列
public class LongestCommonSubString {

    int[][] getdp(char[] str1, char[] str2) {
        int[][] dp = new int[str1.length][str2.length];
        for (int i = 0; i < str1.length; i++) {
            if(str1[i]==str2[0])
                dp[i][0] = 1;
        }
        for (int j = 0; j < str2.length; j++) {
            if(str2[j]==str1[0])
                dp[0][j] = 1;
        }
        for (int i = 1; i < str1.length; i++) {
            for (int j = 1; j < str2.length; j++) {
                if(str1[i]==str2[j])
                    dp[i][j] = dp[i - 1][j - 1] + 1;
            }
        }

        return dp;
    }

    public String longestCommonSubString(String str1, String str2) {
        if (str1 == null || str2 == null || str1.equals("") || str2.equals("")) {
            return "";
        }
        char[] chs1 = str1.toCharArray();
        char[] chs2 = str2.toCharArray();
        int[][] dp = getdp(chs1, chs2);
        int end = 0;
        int max = 0;
        for (int i = 0; i < chs1.length; i++) {
            for (int j = 0; j < chs2.length; j++) {
                if (dp[i][j] > max) {
                    max = dp[i][j];
                    end = i;
                }
            }
        }
        // [end-max+1...end] == [end-max+1...end+1)
        return str1.substring(end - max + 1, end + 1);
    }

    public static void main(String[] args) {
        String str = new LongestCommonSubString().longestCommonSubString("abcef", "bcegdd");
        System.out.println(str);
    }
}
