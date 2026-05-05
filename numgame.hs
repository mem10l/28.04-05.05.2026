import System.Random (randomRIO)

main :: IO ()
main = do
    putStrLn "Welcome to Guess the Number!"
    secret <- randomRIO (1, 100 :: Int)
    gameLoop secret

gameLoop :: Int -> IO ()
gameLoop secret = do
    putStrLn "Enter your guess (1-100):"
    input <- getLine

    let guess = read input :: Int

    if guess < secret then do
        putStrLn "Too low!"
        gameLoop secret
    else if guess > secret then do
        putStrLn "Too high!"
        gameLoop secret
    else
        putStrLn "You got it!"