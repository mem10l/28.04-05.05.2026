import System.IO

main :: IO ()
main = loop []

loop :: [String] -> IO ()
loop items = do
    putStrLn "\nChoose an option: create | read | update | delete | quit"
    command <- getLine

    case command of
        "create" -> do
            putStrLn "Enter value to add:"
            val <- getLine
            let newItems = items ++ [val]
            putStrLn "Item added."
            loop newItems

        "read" -> do
            putStrLn "Current items:"
            printItems items 0
            loop items

        "update" -> do
            putStrLn "Enter index to update:"
            idxStr <- getLine
            putStrLn "Enter new value:"
            newVal <- getLine
            let idx = read idxStr :: Int
            let newItems = updateItem idx newVal items
            loop newItems

        "delete" -> do
            putStrLn "Enter index to delete:"
            idxStr <- getLine
            let idx = read idxStr :: Int
            let newItems = deleteItem idx items
            loop newItems

        "quit" -> putStrLn "Goodbye!"

        _ -> do
            putStrLn "Unknown command."
            loop items

printItems :: [String] -> Int -> IO ()
printItems [] _ = return ()
printItems (x:xs) i = do
    putStrLn (show i ++ ": " ++ x)
    printItems xs (i + 1)

updateItem :: Int -> String -> [String] -> [String]
updateItem _ _ [] = []
updateItem 0 newVal (_:xs) = newVal : xs
updateItem n newVal (x:xs) = x : updateItem (n - 1) newVal xs

deleteItem :: Int -> [String] -> [String]
deleteItem _ [] = []
deleteItem 0 (_:xs) = xs
deleteItem n (x:xs) = x : deleteItem (n - 1) xs