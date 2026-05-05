module Main where

import Data.Char (toLower, toUpper)
import Data.List (intercalate, nub)
import System.IO (hSetBuffering, stdin, stdout, BufferMode(..))
import System.Exit (exitSuccess)

-- Word list
wordList :: [String]
wordList =
  [ "haskell", "functional", "lambda", "monad", "recursion"
  , "compiler", "terminal", "keyboard", "elephant", "universe"
  , "algorithm", "variable", "function", "paradise", "chocolate"
  , "adventure", "dinosaur", "telescope", "hurricane", "symphony"
  , "labyrinth", "mystical", "perplexed", "wandering", "absolute"
  ]

maxWrong :: Int
maxWrong = 6

-- Hangman ASCII art stages
hangmanArt :: Int -> [String]
hangmanArt n = base ++ body
  where
    base =
      [ "  +---+"
      , "  |   |"
      ]
    body = case n of
      0 -> [ "      |"
           , "      |"
           , "      |"
           , "      |"
           , "========" ]
      1 -> [ "  O   |"
           , "      |"
           , "      |"
           , "      |"
           , "========" ]
      2 -> [ "  O   |"
           , "  |   |"
           , "      |"
           , "      |"
           , "========" ]
      3 -> [ "  O   |"
           , " /|   |"
           , "      |"
           , "      |"
           , "========" ]
      4 -> [ "  O   |"
           , " /|\\  |"
           , "      |"
           , "      |"
           , "========" ]
      5 -> [ "  O   |"
           , " /|\\  |"
           , " /    |"
           , "      |"
           , "========" ]
      _ -> [ "  O   |"
           , " /|\\  |"
           , " / \\  |"
           , "      |"
           , "========" ]

-- Display the current word with guessed letters revealed
displayWord :: String -> [Char] -> String
displayWord word guessed =
  intercalate " " $ map reveal word
  where
    reveal c
      | toLower c `elem` guessed = [toUpper c]
      | otherwise                = "_"

-- Check win condition
isWon :: String -> [Char] -> Bool
isWon word guessed = all (\c -> toLower c `elem` guessed) word

-- Pretty divider
divider :: String
divider = replicate 40 '-'

-- Clear screen (ANSI)
clearScreen :: IO ()
clearScreen = putStr "\ESC[2J\ESC[H"

-- Render full game state
renderGame :: String -> [Char] -> [Char] -> IO ()
renderGame word guessed wrong = do
  clearScreen
  putStrLn "\n  +======================================+"
  putStrLn   "  |           H A N G M A N             |"
  putStrLn   "  +======================================+\n"
  mapM_ (\l -> putStrLn $ "    " ++ l) (hangmanArt (length wrong))
  putStrLn ""
  putStrLn $ "  Word:  " ++ displayWord word guessed
  putStrLn ""
  putStrLn divider
  putStrLn $ "  Wrong guesses (" ++ show (length wrong) ++ "/" ++ show maxWrong ++ "):  "
             ++ if null wrong then "none" else map toUpper wrong
  putStrLn $ "  Remaining lives: " ++ replicate (maxWrong - length wrong) 'o'
                                   ++ replicate (length wrong) 'x'
  putStrLn divider

-- Pick a word by index (simple deterministic "random" based on user input)
pickWord :: Int -> String
pickWord n = wordList !! (n `mod` length wordList)

-- Main game loop
gameLoop :: String -> [Char] -> [Char] -> IO ()
gameLoop word guessed wrong = do
  renderGame word guessed wrong
  if isWon word guessed
    then do
      putStrLn "\n  *** YOU WIN! Well done! ***\n"
      playAgain
    else if length wrong >= maxWrong
      then do
        putStrLn $ "\n  GAME OVER! The word was: " ++ map toUpper word ++ "\n"
        playAgain
      else do
        putStr "\n  Guess a letter: "
        input <- getLine
        case input of
          "quit" -> do putStrLn "  Thanks for playing!"; exitSuccess
          [c]   -> do
            let letter = toLower c
            if letter `elem` guessed || letter `elem` wrong
              then do
                putStrLn "  Already guessed that one!"
                gameLoop word guessed wrong
              else if letter `elem` map toLower word
                then gameLoop word (letter : guessed) wrong
                else gameLoop word guessed (letter : wrong)
          _ -> do
            putStrLn "  Please enter a single letter."
            gameLoop word guessed wrong

playAgain :: IO ()
playAgain = do
  putStr "  Play again? (y/n): "
  ans <- getLine
  case map toLower ans of
    "y" -> startGame
    "n" -> do putStrLn "  See you next time!\n"; exitSuccess
    _   -> playAgain

startGame :: IO ()
startGame = do
  clearScreen
  putStrLn "\n  +======================================+"
  putStrLn   "  |           H A N G M A N             |"
  putStrLn   "  +======================================+\n"
  putStrLn   "  Guess the hidden word, one letter at a time."
  putStrLn   "  You have 6 wrong guesses before the man hangs."
  putStrLn   "  Type 'quit' to exit.\n"
  putStr     "  Enter a number to pick a word (any number): "
  input <- getLine
  case reads input :: [(Int, String)] of
    [(n, _)] -> gameLoop (pickWord n) [] []
    _        -> gameLoop (pickWord 42) [] []

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  hSetBuffering stdin  LineBuffering
  startGame