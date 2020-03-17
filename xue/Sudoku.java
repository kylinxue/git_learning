package xue;
// 1
public class Sudoku {

    char puzzle = '.';

    public void solveSudoku(char[][] board) {
        boolean[][] row = new boolean[9][9];
        boolean[][] col = new boolean[9][9];
        boolean[][] block = new boolean[9][9];

        // 初始化board
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                if (board[i][j] != puzzle) {
                    int num = board[i][j] - '1';
                    row[i][num]=true;
                    col[j][num]=true;
                    int blockIndex = i/3*3+j/3;
                    block[blockIndex][num]=true;
                }
            }
        }
        dfs(board, row, col, block, 0, 0);
    }

    // 0表示没有填入
    private boolean dfs(char[][] board, boolean[][] row, boolean[][] col, boolean[][] block, int i, int j) {
        // 如果i,j 不需要填, 看 i, j+1
        while (board[i][j] != puzzle) {
            if (++j >= 9) {
                i++;
                j=0;
            }
            if(i>=9)
                return true;
        }
        for (int num = 0; num < 9; num++) {
            int blockIndex = i/3*3 + j/3;
            if(!row[i][num] && !col[j][num] && !block[blockIndex][num]){
                board[i][j]=(char) ('1'+num);
                row[i][num]=true;
                col[j][num]=true;
                block[blockIndex][num]=true;
                if (dfs(board, row, col, block, i, j )) { // while循环帮忙迭代
                    return true;
                }
                // 清除状态，试下一个num
                board[i][j]=puzzle;
                row[i][num]=false;
                col[j][num]=false;
                block[blockIndex][num]=false;
            }
        }

        return false;
    }

    private void printBoard(char[][] board) {
        for (int i = 0; i < 9; i++) {
            for (int j = 0; j < 9; j++) {
                System.out.print(board[i][j] + " ");
            }
            System.out.println();
        }
    }

    public static void main(String[] args) {
        char[][] board = new char[][]{
                {'5', '3', '.', '.', '7', '.', '.', '.', '.'},
                {'6', '.', '.', '1', '9', '5', '.', '.', '.'},
                {'.', '9', '8', '.', '.', '.', '.', '6', '.'},
                {'8', '.', '.', '.', '6', '.', '.', '.', '3'},
                {'4', '.', '.', '8', '.', '3', '.', '.', '1'},
                {'7', '.', '.', '.', '2', '.', '.', '.', '6'},
                {'.', '6', '.', '.', '.', '.', '2', '8', '.'},
                {'.', '.', '.', '4', '1', '9', '.', '.', '5'},
                {'.', '.', '.', '.', '8', '.', '.', '7', '9'}
        };
        Sudoku solution = new Sudoku();
        solution.printBoard(board);
        solution.solveSudoku(board);
        solution.printBoard(board);
    }
}
