package xue;

import java.util.ArrayList;
import java.util.List;

// 二叉搜索树有效性判定
public class ValidateBST {

    static class Node {
        public Node left;
        public Node right;
        public int val;
        public Node(int val){
            this.val = val;
        }
    }

    void inorder(Node head, List<Integer> list) {
        if (head == null) {
            return;
        }
        inorder(head.left, list);
        list.add(head.val);
        inorder(head.right, list);
    }

    // 中序遍历，如果不是递增序列，则不是二叉搜索树
    public boolean isValidate(Node head) {
        if (head == null) {
            return true;
        }
        List<Integer> list = new ArrayList<>();
        inorder(head, list);
        for (int i = 1; i < list.size(); i++) {
            if (list.get(i - 1) > list.get(i)) {
                return false;
            }
        }

        return true;
    }

    public static void main(String[] args) {
        // 构造树
        Node n1 = new Node(1);
        Node n2 = new Node(2);
        Node n3 = new Node(3);
        n1.left = n2; n1.right = n3;
        Node n4 = new Node(4);
        Node n5 = new Node(5);
        n2.left = n4; n2.right = n5;

        List<Integer> list = new ArrayList<>();
        new ValidateBST().inorder(n1, list);
        System.out.println(list);
    }
}
