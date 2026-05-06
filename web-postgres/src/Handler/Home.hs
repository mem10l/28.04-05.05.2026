{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Home where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)
import Text.Julius (RawJS (..))

-- 1. Define the Data Type FIRST
data FileForm = FileForm
    { fileInfo :: FileInfo
    , fileDescription :: Text
    }

-- 2. Define the Handler
getHomeR :: Handler Html
getHomeR = do
    (formWidget, formEnctype) <- generateFormPost sampleForm
    let submission = Nothing :: Maybe FileForm
        handlerName = "getHomeR" :: Text
    allComments <- runDB $ getAllComments

    defaultLayout $ do
        -- 1. Define IDs and Identifiers here
        let (commentFormId, commentTextareaId, commentListId) = commentIds
        aDomId <- newIdent  -- This must stay inside the 'do' block
        
        setTitle "VibeArch - Music"
        
        -- 2. NOW call the widget
        $(widgetFile "homepage")

postHomeR :: Handler Html
postHomeR = do
    ((result, formWidget), formEnctype) <- runFormPost sampleForm
    let handlerName = "postHomeR" :: Text
        submission = case result of
            FormSuccess res -> Just res
            _ -> Nothing
    allComments <- runDB $ getAllComments

    defaultLayout $ do
        let (commentFormId, commentTextareaId, commentListId) = commentIds
        aDomId <- newIdent -- Ensure it's here too
        
        setTitle "VibeArch - Music"
        $(widgetFile "homepage")

-- 4. The rest of the helper functions
sampleForm :: Form FileForm
sampleForm = renderBootstrap3 BootstrapBasicForm $ FileForm
    <$> fileAFormReq "Choose a file"
    <*> areq textField "What's on the file?" Nothing

commentIds :: (Text, Text, Text)
commentIds = ("js-commentForm", "js-createCommentTextarea", "js-commentList")

getAllComments :: DB [Entity Comment]
getAllComments = selectList [] [Asc CommentId]