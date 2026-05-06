{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Artists where -- Or Handler.Discover, etc.

import Import

getArtistsR :: Handler Html
getArtistsR = defaultLayout $ do
    setTitle "Artists - VibeArch"
    $(widgetFile "artists")