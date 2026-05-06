{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Artists (getArtistsR) where
import Import

getArtistsR :: Handler Html
getArtistsR = do
    -- Add the type signature line below:
    let artists :: [Text]
        artists = ["The Haskellers", "Monad Crew", "Lazy Evaluation"]
        
    defaultLayout $ do
        setTitle "Artists - VibeArch"
        $(widgetFile "artists")