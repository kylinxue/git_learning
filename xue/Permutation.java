package xue;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

// 输入一个只有整数0~9组成的字符串，输出利用输入的全部数字元素（且必须使用1次）组成的不同排列组合的个数
public class Permutation {
    public String[] permutation(String S) {
        char[] chars = S.toCharArray();
        Arrays.sort(chars);
        boolean[] book = new boolean[chars.length];
        StringBuilder sb = new StringBuilder();
        List<String> res = new ArrayList<>();
        dfs(res, sb, book, chars);
        String[] s = new String[res.size()];
        for(int i=0; i<s.length; i++){
            s[i]=res.get(i);
        }
        return s;
    }

    void dfs(List<String> res, StringBuilder sb, boolean[] book, char[] chars){
        if(sb.length() == chars.length){
            res.add(sb.toString());
            return;
        }
        for(int i=0; i<chars.length; i++){
            if(book[i])
                continue;
            if(i>0 && chars[i]==chars[i-1] && !book[i-1])
                continue;
            sb.append(chars[i]);
            book[i]=true;
            dfs(res, sb, book, chars);
            book[i]=false;
            sb.deleteCharAt(sb.length()-1);
        }
    }

    public static void main(String[] args) {
        String nums = "0030";
        String[] s = new Permutation().permutation(nums);
        System.out.println("stop");
    }
}
