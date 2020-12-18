--- 迷宫游戏
--- @module Maze Module
--- @copyright Lilith Games, Avatar Team
--- @author Yuancheng Zhang
local Maze, this = ModuleUtil.New('Maze', ServerBase)

-- Const
local NUM_ROWS, NUM_COLS = 24, 24
local LEFT, UP, RIGHT, DOWN, VISITED = 1, 2, 3, 4, 5
local WALL_ARCH = 'Maze_Wall_Test'
local CELL_SIDE = 2

local WALL_ROOT_CENTER = Vector3(100, 1.5, 0)

local WALL_ROOT_NODE = world.MiniGames.Game_03_Maze.Walls
local WALL_POS_OFFSET = 1
local CELL_POS_OFFSET = CELL_SIDE
local WALL_DICT = {}
local WALL_ROOT_POS = WALL_ROOT_CENTER + Vector3(-NUM_COLS, 0, NUM_ROWS) * CELL_SIDE * .5
WALL_DICT[LEFT] = {
    pos = WALL_ROOT_POS + Vector3.Left * WALL_POS_OFFSET,
    rot = EulerDegree(0, -90, 0),
    dir = 'L'
}
WALL_DICT[UP] = {
    pos = WALL_ROOT_POS + Vector3.Forward * WALL_POS_OFFSET,
    rot = EulerDegree(0, 0, 0),
    dir = 'U'
}
WALL_DICT[RIGHT] = {
    pos = WALL_ROOT_POS + Vector3.Right * WALL_POS_OFFSET,
    rot = EulerDegree(0, 90, 0),
    dir = 'R'
}
WALL_DICT[DOWN] = {
    pos = WALL_ROOT_POS + Vector3.Back * WALL_POS_OFFSET,
    rot = EulerDegree(0, 180, 0),
    dir = 'D'
}

-- The array M is going to hold the array information for each cell.
-- The first four coordinates tell if walls exist on those sides
-- and the fifth indicates if the cell has been visited in the search.
-- M(LEFT, UP, RIGHT, DOWN, CHECK_IF_VISITED)
local M = {}

-- Set starting row and column
local r, c = 1, 1

-- # The history is the stack of visited locations
local history = Stack:New()

--! 打印事件日志, true:开启打印
local showLog, PrintMazeData = false

function Maze:Init()
    print('Maze:Init')
    InitData()
    MazeDataInit()
    MazeDataGen()
    PrintMazeData()
    invoke(MazeWallGen)
end

function InitData()
end

function MazeDataInit()
    for row = 1, NUM_ROWS do
        M[row] = {}
        for col = 1, NUM_COLS do
            M[row][col] = {0, 0, 0, 0, 0}
        end
    end
end

function MazeDataGen()
    r, c = 1, 1
    -- cell data
    local cell = {r, c}
    -- unvisited cell direction
    local check
    -- move direction
    local dir

    history:Clear()
    history:Push(cell)

    while not history:IsEmpty() do
        -- designate this location as visited
        M[r][c][VISITED] = 1
        -- check if the adjacent cells are valid for moving to
        check = {}
        if c > 1 and M[r][c - 1][VISITED] == 0 then
            table.insert(check, LEFT)
        end
        if r > 1 and M[r - 1][c][VISITED] == 0 then
            table.insert(check, UP)
        end
        if c < NUM_COLS and M[r][c + 1][VISITED] == 0 then
            table.insert(check, RIGHT)
        end
        if r < NUM_ROWS and M[r + 1][c][VISITED] == 0 then
            table.insert(check, DOWN)
        end

        -- If there is a valid cell to move to.
        -- Mark the walls between cells as open if we move
        if #check > 0 then
            history:Push({r, c})
            dir = table.shuffle(check)[1]
            if dir == LEFT then
                M[r][c][LEFT] = 1
                c = c - 1
                M[r][c][RIGHT] = 1
            end
            if dir == UP then
                M[r][c][UP] = 1
                r = r - 1
                M[r][c][DOWN] = 1
            end
            if dir == RIGHT then
                M[r][c][RIGHT] = 1
                c = c + 1
                M[r][c][LEFT] = 1
            end
            if dir == DOWN then
                M[r][c][DOWN] = 1
                r = r + 1
                M[r][c][UP] = 1
            end
        else
            cell = history:Pop()
            r, c = cell[1], cell[2]
        end
    end

    -- Open the walls at the start and finish
    M[1][1][LEFT] = 1
    M[NUM_ROWS][NUM_COLS][RIGHT] = 1
end

function MazeWallGen()
    local wallName
    local objWall
    local cell, pos, rot
    for row = 1, NUM_ROWS do
        for col = 1, NUM_COLS do
            cell = M[row][col]
            for dir = 1, 4 do
                if cell[dir] == 0 then
                    wallName = string.format('%s_%s_%s_%s', WALL_ARCH, row, col, WALL_DICT[dir].dir)
                    pos = Vector3(col * CELL_POS_OFFSET, 0, row * -CELL_POS_OFFSET) + WALL_DICT[dir].pos
                    rot = WALL_DICT[dir].rot
                    objWall = world:CreateInstance(WALL_ARCH, wallName, WALL_ROOT_NODE, pos, rot)
                end
            end
            wait()
        end
    end
end

PrintMazeData = showLog and function()
        for row = 1, NUM_ROWS do
            for col = 1, NUM_COLS do
                print(table.dump(M[row][col]))
            end
            print('============================')
        end
    end or function()
    end

return Maze
