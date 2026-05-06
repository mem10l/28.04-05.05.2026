{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Library where -- Or Handler.Discover, etc.

import Import

getLibraryR :: Handler Html
getLibraryR = defaultLayout $ do
    setTitle "Library - VibeArch"
    $(widgetFile "library")