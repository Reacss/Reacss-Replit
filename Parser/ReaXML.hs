module Parser.ReaXML where

import Data.ReaXML
import Parser.Lexer
import Text.Parsec
import Text.Parsec.Combinator
import Text.Parsec.String

reaXML :: Parser ReaXML
reaXML = ReaXML <$> reaXMLTree <* eof

reaXMLTree :: Parser ReaXMLTree
reaXMLTree = many reaXMLNode

reaXMLNode :: Parser ReaXMLNode
reaXMLNode
  = ReaXMLTextNode <$> reaXMLText
  <|> ReaXMLElementNode <$> reaXMLElement

reaXMLText :: Parser ReaXMLText
reaXMLText = encodedString

reaXMLElement :: Parser ReaXMLElement
reaXMLElement = do
  symbol $ pure openAngularBraceToken
  n <- reaXMLName
  a <- many reaXMLAttribute
  symbol $ pure closeAngularBraceToken
  c <- reaXMLTree
  symbol openAngularBraceSlashTokens
  symbol n
  symbol $ pure closeAngularBraceToken
  pure $ ReaXMLElement n a c

reaXMLAttribute :: Parser ReaXMLAttribute
reaXMLAttribute = do
  n <- reaXMLName
  symbol $ pure equalToken
  v <- reaXMLValue
  pure $ ReaXMLAttribute n v

reaXMLName :: Parser ReaXMLName
reaXMLName = lexeme identifier

reaXMLValue :: Parser ReaXMLValue
reaXMLValue = lexeme quotedString