{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Library (getLibraryR, postLibraryR, postDeleteTrackR) where

import Import

-- 1. THE POST HANDLER (Only define this ONCE)
postLibraryR :: Handler Html
postLibraryR = do
    uid <- requireAuthId -- Ensure user is logged in
    track <- runInputPost $ ireq textField "track"
    artist <- runInputPost $ ireq textField "artist"
    
    -- Insert into Postgres (insertBy prevents duplicates if Unique is set)
    _ <- runDB $ insertBy $ LibraryItem uid track artist
    
    setMessage "Track added to your library!"
    redirect DiscoverR

-- 2. THE GET HANDLER
getLibraryR :: Handler Html
getLibraryR = do
    uid <- requireAuthId
    -- Template needs muid, so we wrap our uid
    let muid = Just uid 
    
    -- Get token for the delete button form
    req <- getRequest
    let tokenTicket = maybe "" id (reqToken req)

    -- Fetch tracks from Postgres for this specific user
    userTracks <- runDB $ selectList [LibraryItemUserId ==. uid] [Asc LibraryItemTrackName]
    
    defaultLayout $ do
        setTitle "My Library"
        $(widgetFile "library")

postDeleteTrackR :: LibraryItemId -> Handler Html
postDeleteTrackR itemId = do
    uid <- requireAuthId
    
    -- Check if this item actually belongs to the logged-in user
    -- This prevents users from deleting each other's tracks!
    libraryItem <- runDB $ get404 itemId
    if libraryItemUserId libraryItem /= uid
        then permissionDenied "You don't own this track."
        else do
            runDB $ delete itemId
            setMessage "Track removed from library."
            redirect LibraryR