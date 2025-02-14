module Main where

import Prelude

-- 基本の Effect/非同期処理関連
import Effect (Effect)
import Effect.Aff (Aff, launchAff, catchError)
import Effect.Ref as Ref

-- HTTP 通信および JSON デコード用（例：purescript-affjax, argonaut-decode）
import Affjax (get, AffjaxResponse)
-- Affjax.Response は存在しないので、レスポンス本体は `response` フィールドを使う

import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)

-- Array や Maybe の操作
import Data.Array (map)
import Data.Maybe (Maybe(..))

-- purescript-jelly のコンポーネント・フック・HTML生成用モジュール
import Jelly.Component (Component, component)
import Jelly.Hooks (useState, useEffect)
import Jelly.Html as HTML
import Jelly.Props (prop)

-- ------------------------------------------------------------
-- 型定義と JSON のデコードインスタンス
-- ------------------------------------------------------------

-- Pokemon 型（name と url の2つのフィールドを持つレコード）
type Pokemon = 
  { name :: String
  , url  :: String
  }

-- API レスポンスは results フィールドに Pokemon の配列を持つ。
-- React 側では初期値 undefined となっているので、
-- purescript 側では「まだ値がセットされていない」状態を Maybe で表現します。
type PokemonResponse = 
  { results :: Array Pokemon
  }

instance decodePokemon :: DecodeJson Pokemon where
  decodeJson = 
    -- JSON オブジェクトから name, url を取り出す実装（各自実装してください）
    error "decodePokemon: 実装してください"

instance decodePokemonResponse :: DecodeJson PokemonResponse where
  decodeJson =
    -- JSON オブジェクトから results フィールドを取り出す実装（各自実装してください）
    error "decodePokemonResponse: 実装してください"


-- ------------------------------------------------------------
-- HTTP 通信: PokemonResponse を取得する
-- ------------------------------------------------------------

fetchPokemonResponse :: String -> Aff (Maybe PokemonResponse)
fetchPokemonResponse url =
  catchError (do
    response <- get url  -- type: AffjaxResponse Json
    case decodeJson response.response of
      Left _err -> pure Nothing
      Right pr  -> pure (Just pr)
  ) (\_ -> pure Nothing)


-- ------------------------------------------------------------
-- コンポーネント定義
-- ------------------------------------------------------------

app :: Component
app = component \_ -> do
  -- 状態は「PokemonResponse が取得できたかどうか」
  -- 初期状態は Nothing（＝未取得）
  (state, setState) <- useState Nothing

  -- 副作用フック：コンポーネントマウント時に API を叩く
  useEffect \_ -> do
    -- マウント解除時に結果が反映されないようにするためのフラグ
    ignoreRef <- Ref.new false

    -- 非同期で API 取得を実行
    launchAff do
      result <- fetchPokemonResponse "https://pokeapi.co/api/v2/pokemon/?offset=0&limit=10"
      ignored <- Ref.read ignoreRef
      if not ignored then
        setState result
      else
        pure unit

    -- クリーンアップ関数：アンマウント時に ignore フラグを立てる
    pure (Ref.write ignoreRef true)

  -- レンダリング
  pure $
    HTML.div [] $
      case state of
        Nothing -> []  -- まだデータがない場合は空
        Just response ->
          -- 取得できた場合は results の各要素をレンダリング
          map renderPokemon response.results


-- ------------------------------------------------------------
-- 個々の Pokemon をレンダリングする関数
-- ------------------------------------------------------------

renderPokemon :: Pokemon -> HTML.Html
renderPokemon pokemon =
  HTML.div [ prop "key" pokemon.name ]
    [ HTML.p [] [ HTML.text pokemon.name ]
    , HTML.p [] [ HTML.text pokemon.url ]
    ]
