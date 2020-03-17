package xue;

// 5
public class ReverseParseString {

    public String reverseByRecursion(char[] chars,int[] index) {
        String str = "";   // 每一次递归保证返回递归过程中的字符串
        while(index[0]>=0) {
            if (chars[index[0]] != '(' && chars[index[0]] != ')') {
                str += chars[index[0]--];
            } else if (chars[index[0]] == '(') {
                // 重复次数
                int r = index[0]-1;
                int l = r;
                int cnt = 0;
                while(chars[l]>='0' && chars[l]<='9'){
                    cnt += (chars[l]-'0')*(int)(Math.pow(10, r-l));
                    l--;
                }
                index[0] = l;    // (l, r] 组成数

                StringBuilder tmp = new StringBuilder();
                while (cnt-- > 0) {
                    tmp.append(str);
                }
                str = tmp.toString();
                return str;
            } else if (chars[index[0]] == ')'){
                index[0]--;
                str += reverseByRecursion(chars, index);
            }
        }

        return str;
    }

    public static void main(String[] args) {
        String s = "ab2[3(cd)]e";
        s = s.replace("{", "(");
        s = s.replace("[", "(");
        s = s.replace("}", ")");
        s = s.replace("]", ")");
        String res = new ReverseParseString().reverseByRecursion(s.toCharArray(), new int[]{s.length()-1});
        System.out.println(res);
    }
}
