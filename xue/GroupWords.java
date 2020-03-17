package xue;

import java.util.*;

// 2
public class GroupWords {

    // todo 可以尝试使用 并查集 进行分组
    public List<List<String>> groupStrings(String[] strings) {
        HashMap<String, List<String>> groups = new HashMap<>();
        for (String str : strings) {
            String key = key(str);
            if (!groups.containsKey(key)) {
                ArrayList<String> list = new ArrayList<>();
                list.add(str);
                groups.put(key, list);
            } else {
                groups.get(key).add(str);
            }
        }
        List<List<String>> res = new ArrayList<>();
        res.addAll(groups.values());
        return res;
    }

    // 每个字符串任意交换位置，只要每个字符数相同即可
    private String key(String a) {
        char[] ac = a.toCharArray();
        Arrays.sort(ac);
        return String.valueOf(ac);
    }

    private boolean inSameGroup(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }
        // 记录每个字符->个数
        HashMap<Character, Integer> map = new HashMap<>();
        char[] ac = a.toCharArray();
        char[] bc = b.toCharArray();
        for (int i = 0; i < ac.length; i++) {
            if (!map.containsKey(ac[i])) {
                map.put(ac[i], 1);
            } else {
                map.put(ac[i], map.get(ac[i]) + 1);
            }
        }
        for (int i = 0; i < bc.length; i++) {
            if(!map.containsKey(bc[i]))
                return false;
            map.put(bc[i], map.get(bc[i]) - 1);
            if (map.get(bc[i]) < 0) {
                return false;
            }
        }
        return true;
    }

    public static void main(String[] args) {
//        List<List<String>> b = new GroupWords().groupStrings(new String[] {"abcb", "bcad", "xyz", "zxy", "ddd"});
////        System.out.println(b);


    }
}
