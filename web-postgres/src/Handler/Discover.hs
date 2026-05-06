{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Discover (getDiscoverR) where
import Import

getDiscoverR :: Handler Html
getDiscoverR = do
    let newReleases :: [(Text, Text)]
        newReleases = [("Neon Nights", "Synthwave"), ("Arch Bliss", "Ambient")]
    
    -- Get the current request and extract the token
    req <- getRequest
    let tokenTicket = maybe "" id (reqToken req)
    
    defaultLayout $ do
        setTitle "Discover - VibeArch"
        $(widgetFile "discover")