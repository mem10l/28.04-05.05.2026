{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Discover (getDiscoverR) where 

import Import

getDiscoverR :: Handler Html
getDiscoverR = defaultLayout $ do
    setTitle "Discover - VibeArch"
    $(widgetFile "discover")