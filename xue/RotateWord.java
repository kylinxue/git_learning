package xue;

import java.util.Stack;

// 10
public class RotateWord {

    public void rotateWord_1(String[] args) {
        String s = " bag  boc good";
        s = s.trim().replaceAll(" +", " ");
        String[] strs = s.split(" ");
        Stack<String> stack = new Stack<>();
        for (String str : strs) {
            stack.push(str);
        }
        StringBuilder sb = new StringBuilder();
        while (!stack.isEmpty()) {
            sb.append(stack.pop() + " ");
        }

        System.out.println(sb.toString());
    }

    private void reverseWord(char[] chs, int s, int e) {
        if (chs == null) return;
        while (s < e) {
            char t = chs[s];
            chs[s] = chs[e];
            chs[e] = t;
            s++;
            e--;
        }
    }

    public void rotateWord_2(char[] chars) {
        if (chars == null || chars.length == 0) {
            return;
        }
        int l = -1, r = -1;
        reverseWord(chars, 0, chars.length - 1);
        for (int i = 0; i < chars.length; i++) {
            if (chars[i] != ' ') {
                l = i == 0 || chars[i - 1] == ' ' ? i : l;
                r = i == chars.length - 1 || chars[i + 1] == ' ' ? i : r;
            }
            if (l != -1 && r != -1) { // 说明找到一个单词的起止位置
                reverseWord(chars, l, r);
                l=-1; r=-1;
            }
        }

    }

    void testChars(char[] chs) {

    }

    public static void main(String[] args) {
        String s = " bag  boc good";
        char[] chs = s.toCharArray();
        new RotateWord().rotateWord_2(chs);

        System.out.println(chs);
    }
}
