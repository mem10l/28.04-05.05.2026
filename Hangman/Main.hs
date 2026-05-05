module Main where

import Data.Char (toLower, toUpper)
import Data.List (intercalate)
import System.IO (hSetBuffering, stdin, stdout, BufferMode(..))
import System.Exit (exitSuccess)
import System.Random (randomRIO)

maxWrong :: Int
maxWrong = 6

main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  hSetBuffering stdin  LineBuffering

  content <- readFile "word.txt"
  let wordList = words content

  startGame wordList

-- =========================
-- GAME START
-- =========================

startGame :: [String] -> IO ()
startGame wordList = do
  clearScreen
  putStrLn "\n  +======================================+"
  putStrLn   "  |           H A N G M A N             |"
  putStrLn   "  +======================================+\n"

  word <- randomWord wordList
  gameLoop wordList word [] []

-- =========================
-- RANDOM WORD
-- =========================

randomWord :: [String] -> IO String
randomWord [] = return "haskell"
randomWord ws = do
  i <- randomRIO (0, length ws - 1)
  return (ws !! i)

-- =========================
-- GAME LOOP
-- =========================

gameLoop :: [String] -> String -> [Char] -> [Char] -> IO ()
gameLoop wordList word guessed wrong = do
  renderGame word guessed wrong

  if isWon word guessed
    then do
      putStrLn "\n  *** YOU WIN! Well done! ***\n"
      playAgain wordList

    else if length wrong >= maxWrong
      then do
        putStrLn $ "\n  GAME OVER! The word was: " ++ map toUpper word ++ "\n"
        playAgain wordList

    else do
      putStr "\n  Guess a letter: "
      input <- getLine

      case input of
        "quit" -> do
          putStrLn "  Thanks for playing!"
          exitSuccess

        [c] -> do
          let letter = toLower c

          if letter `elem` guessed || letter `elem` wrong
            then do
              putStrLn "  Already guessed that one!"
              gameLoop wordList word guessed wrong

            else if letter `elem` map toLower word
              then gameLoop wordList word (letter : guessed) wrong
              else gameLoop wordList word guessed (letter : wrong)

        _ -> do
          putStrLn "  Please enter a single letter."
          gameLoop wordList word guessed wrong

-- =========================
-- PLAY AGAIN
-- =========================

playAgain :: [String] -> IO ()
playAgain wordList = do
  putStr "  Play again? (y/n): "
  ans <- getLine

  case map toLower ans of
    "y" -> startGame wordList
    "n" -> do
      putStrLn "  See you next time!\n"
      exitSuccess
    _ -> playAgain wordList

-- =========================
-- DISPLAY
-- =========================

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

  putStrLn $ "  Wrong guesses (" ++ show (length wrong) ++ "/" ++ show maxWrong ++ "): "
             ++ if null wrong then "none" else map toUpper wrong

  putStrLn $ "  Remaining lives: "
             ++ replicate (maxWrong - length wrong) 'o'
             ++ replicate (length wrong) 'x'

  putStrLn divider

-- =========================
-- LOGIC
-- =========================

displayWord :: String -> [Char] -> String
displayWord word guessed =
  intercalate " " $ map reveal word
  where
    reveal c
      | toLower c `elem` guessed = [toUpper c]
      | otherwise = "_"

isWon :: String -> [Char] -> Bool
isWon word guessed =
  all (\c -> toLower c `elem` guessed) word

-- =========================
-- ASCII ART
-- =========================

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

-- =========================
-- UTIL
-- =========================

divider :: String
divider = replicate 40 '-'

clearScreen :: IO ()
clearScreen = putStr "\ESC[2J\ESC[H"