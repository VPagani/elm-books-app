port module Main exposing (main)

import Array
import Browser
import Browser.Navigation as Nav
import Collection exposing (Collection)
import Date
import Html exposing (..)
import Html.Attributes as Attr exposing (class, style)
import Html.Events as Ev
import Html.Lazy exposing (lazy)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Set
import Time exposing (Month(..))
import Url
import Utils



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }


port saveData : String -> Cmd msg


port updatedData : (String -> msg) -> Sub msg


port clear : (() -> msg) -> Sub msg


port reset : (() -> msg) -> Sub msg


init : String -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init serializedData _ key =
    update (UpdatedData serializedData) (Model (initState key) initData)


emptyData : Data
emptyData =
    Data Collection.empty Collection.empty Collection.empty


initData : Data
initData =
    let
        authors =
            Collection.fromList
                [ Author 1 "J. K. Rowling"
                , Author 2 "George R. R. Martin"
                , Author 3 "Douglas Adams"
                ]

        genres =
            Collection.fromList
                [ Genre 1 "Adventure"
                , Genre 2 "Fantasy"
                , Genre 3 "Fiction"
                , Genre 4 "Science Fiction"
                ]

        date day month year =
            Date.fromCalendarDate year month day

        books =
            Collection.fromList
                [ Book 1 "Harry Potter and the Sorcerer's Stone" 1 (Set.fromList [ 1, 2, 3 ]) (date 26 Jun 1997) "https://kbimages1-a.akamaihd.net/ca35b0df-52d8-44cd-ad10-1d1ae7828317/240/240/False/harry-potter-and-the-philosopher-s-stone-3.jpg"
                , Book 2 "Harry Potter and the Chamber of Secrets" 1 (Set.fromList [ 1, 2, 3 ]) (date 2 Jul 1998) "https://kbimages1-a.akamaihd.net/645388ae-94f7-41fe-8416-f3929f43414f/240/240/False/harry-potter-and-the-chamber-of-secrets-5.jpg"
                , Book 3 "Harry Potter and the Prisoner of Azkaban" 1 (Set.fromList [ 1, 2, 3 ]) (date 8 Jul 1999) "https://kbimages1-a.akamaihd.net/8fb7d2a8-fe85-40b7-9661-63d87772a968/240/240/False/harry-potter-and-the-prisoner-of-azkaban-5.jpg"
                , Book 4 "Harry Potter and the Goblet of Fire" 1 (Set.fromList [ 1, 2, 3 ]) (date 9 Jul 2000) "https://kbimages1-a.akamaihd.net/2667210b-30b6-424d-bfa0-c9e6c54d4d6d/240/240/False/harry-potter-and-the-goblet-of-fire-5.jpg"
                , Book 5 "Harry Potter and the Order of the Phoenix" 1 (Set.fromList [ 1, 2, 3 ]) (date 21 Jun 2003) "https://kbimages1-a.akamaihd.net/36542b55-5eff-4a9d-924d-f5ee2c7e18bb/240/240/False/harry-potter-and-the-order-of-the-phoenix-6.jpg"
                , Book 6 "Harry Potter and the Half-Blood Prince" 1 (Set.fromList [ 1, 2, 3 ]) (date 16 Jul 2005) "https://kbimages1-a.akamaihd.net/cdf07ffb-5b96-43ec-8b7c-5b31002c2a7d/240/240/False/harry-potter-and-the-half-blood-prince-5.jpg"
                , Book 7 "Harry Potter and the Deathly Hollows" 1 (Set.fromList [ 1, 2, 3 ]) (date 21 Jul 2007) "https://kbimages1-a.akamaihd.net/a5483787-d70f-43b9-81dc-e5e3cefdc985/240/240/False/harry-potter-and-the-deathly-hallows-4.jpg"
                , Book 8 "A Game of Thrones (A Song of Ice and Fire)" 2 (Set.fromList [ 1, 2, 3 ]) (date 1 Aug 1996) "https://images-na.ssl-images-amazon.com/images/I/91dSMhdIzTL.jpg"
                , Book 9 "A Clash of Kings (A Song of Ice and Fire)" 2 (Set.fromList [ 1, 2, 3 ]) (date 16 Nov 1998) "https://images-na.ssl-images-amazon.com/images/I/51toTzgHGXL.jpg"
                , Book 10 "A Storm of Swords (A Song of Ice and Fire)" 2 (Set.fromList [ 1, 2, 3 ]) (date 8 Aug 2000) "https://images-na.ssl-images-amazon.com/images/I/51bBrICwrEL.jpg"
                , Book 11 "A Feast for Crows (A Song of Ice and Fire)" 2 (Set.fromList [ 1, 2, 3 ]) (date 17 Oct 2005) "https://images-na.ssl-images-amazon.com/images/I/51s9NYowTlL.jpg"
                , Book 12 "A Dance with Dragons (A Song of Ice and Fire)" 2 (Set.fromList [ 1, 2, 3 ]) (date 12 Jul 2011) "https://images-na.ssl-images-amazon.com/images/I/51o8qUQKpqL.jpg"
                , Book 13 "The Hitchhiker's Guide to the Galaxy" 3 (Set.fromList [ 1, 4 ]) (date 12 Oct 1979) "https://kbimages1-a.akamaihd.net/95611083-7f08-4a2e-893a-aca3544fd750/240/240/False/the-hitchhiker-s-guide-to-the-galaxy-2.jpg"
                , Book 14 "The Restaurant at the End of the Universe" 3 (Set.fromList [ 1, 4 ]) (date 1 Oct 1980) "https://images-na.ssl-images-amazon.com/images/I/51K2qT5APuL.jpg"
                , Book 15 "Life, the Universe and Everything" 3 (Set.fromList [ 1, 4 ]) (date 1 Aug 1982) "https://images-na.ssl-images-amazon.com/images/I/51gpcfiPCmL.jpg"
                , Book 16 "So Long, and Thanks for All the Fish" 3 (Set.fromList [ 1, 4 ]) (date 9 Nov 1984) "https://images-na.ssl-images-amazon.com/images/I/711sBPu8TTL.jpg"
                , Book 17 "Mostly Harmless" 3 (Set.fromList [ 1, 4 ]) (date 1 Oct 1992) "https://images-na.ssl-images-amazon.com/images/I/5132eEdYeVL.jpg"
                ]
    in
    Data authors genres books


initState : Nav.Key -> State
initState key =
    { key = key
    , genreFilter = 0
    , search = ""
    , sortBy = SortByTitle False
    }



-- MODEL


type alias Model =
    { state : State
    , data : Data
    }


type alias State =
    { key : Nav.Key
    , genreFilter : Collection.Id
    , search : String
    , sortBy : SortBy
    }


type SortBy
    = SortByTitle Bool
    | SortByAuthorName Bool
    | SortByReleaseDate Bool


type alias Data =
    { authors : Collection Author
    , genres : Collection Genre
    , books : Collection Book
    }


dataEncode : Data -> Encode.Value
dataEncode data =
    Encode.object
        [ ( "authors", Collection.encode authorEncode data.authors )
        , ( "genres", Collection.encode genreEncode data.genres )
        , ( "books", Collection.encode bookEncode data.books )
        ]


dataDecoder : Decoder Data
dataDecoder =
    Decode.map3 Data
        (Decode.field "authors" <| Collection.decoder authorDecoder)
        (Decode.field "genres" <| Collection.decoder genreDecoder)
        (Decode.field "books" <| Collection.decoder bookDecoder)


type alias Genre =
    { id : Collection.Id
    , title : String
    }


genreEncode : Genre -> Encode.Value
genreEncode genre =
    Encode.object
        [ ( "id", Encode.int genre.id )
        , ( "title", Encode.string genre.title )
        ]


genreDecoder : Decoder Genre
genreDecoder =
    Decode.map2 Genre
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)


type alias Author =
    { id : Collection.Id
    , name : String
    }


authorEncode : Author -> Encode.Value
authorEncode author =
    Encode.object
        [ ( "id", Encode.int author.id )
        , ( "name", Encode.string author.name )
        ]


authorDecoder : Decoder Author
authorDecoder =
    Decode.map2 Author
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)


type alias Book =
    { id : Collection.Id
    , title : String
    , author : Collection.Id
    , genres : Set.Set Collection.Id
    , releaseDate : Date.Date
    , coverUrl : String
    }


bookEncode : Book -> Encode.Value
bookEncode book =
    Encode.object
        [ ( "id", Encode.int book.id )
        , ( "title", Encode.string book.title )
        , ( "author_id", Encode.int book.author )
        , ( "genres_ids", Encode.set Encode.int book.genres )
        , ( "release_date"
          , Encode.object
                [ ( "day", Encode.int <| Date.day book.releaseDate )
                , ( "month", Encode.int <| Date.monthNumber book.releaseDate )
                , ( "year", Encode.int <| Date.year book.releaseDate )
                ]
          )
        , ( "cover_url", Encode.string book.coverUrl )
        ]


bookDecoder : Decoder Book
bookDecoder =
    Decode.map6 Book
        (Decode.field "id" Decode.int)
        (Decode.field "title" Decode.string)
        (Decode.field "author_id" Decode.int)
        (Decode.field "genres_ids" (Decode.list Decode.int |> Decode.map Set.fromList))
        (Decode.field "release_date"
            (Decode.map3 Date.fromCalendarDate
                (Decode.field "day" Decode.int)
                (Decode.field "month" (Decode.int |> Decode.map Date.numberToMonth))
                (Decode.field "year" Decode.int)
            )
        )
        (Decode.field "cover_url" Decode.string)


toSlug : String -> String
toSlug =
    String.replace " " "+"


fromSlug : String -> String
fromSlug =
    String.replace "+" " "



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ updatedData UpdatedData
        , clear (\_ -> ClearData)
        , reset (\_ -> ResetData)
        ]



-- UPDATE


type Msg
    = NoOp
    | UpdatedData String
    | SaveData
    | ClearData
    | ResetData
    | ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | InputSearch String
    | SelectedGenre Collection.Id
    | SelectedSortBy SortBy


update : Msg -> Model -> ( Model, Cmd Msg )
update message ({ state, data } as model) =
    case message of
        NoOp ->
            ( model, Cmd.none )

        UpdatedData serializedData ->
            case Decode.decodeString dataDecoder serializedData of
                Ok newData ->
                    ( { model | data = newData }, Cmd.none )

                Err _ ->
                    update SaveData model

        SaveData ->
            ( model, saveData <| Encode.encode 0 <| dataEncode data )

        ClearData ->
            update SaveData { model | data = emptyData }

        ResetData ->
            update SaveData { model | data = initData }

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.state.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ChangedUrl url ->
            ( model, Cmd.none )

        InputSearch search ->
            ( { model | state = { state | search = search } }, Cmd.none )

        SelectedGenre id ->
            ( { model | state = { state | genreFilter = id } }, Cmd.none )

        SelectedSortBy selectedSortBy ->
            ( { model | state = { state | sortBy = selectedSortBy } }, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view ({ state, data } as model) =
    let
        body =
            [ div [ class "content" ]
                [ viewHeader
                , viewControls model
                , lazy viewBookList model
                ]
            ]
    in
    { title = "Elm Books App"
    , body = body
    }


viewHeader : Html.Html Msg
viewHeader =
    header []
        [ h1 [ class "header__title" ] [ text "Elm Books App" ]
        ]


viewControls : Model -> Html.Html Msg
viewControls { state, data } =
    let
        genreFilter =
            if Collection.exists state.genreFilter data.genres then
                state.genreFilter

            else
                0

        genreOption id title =
            option [ Attr.selected (genreFilter == id), Attr.value <| String.fromInt id ] [ text title ]

        sortByOptions =
            Array.fromList <|
                [ ( "Title: A to Z", SortByTitle False )
                , ( "Title: Z to A", SortByTitle True )
                , ( "Author: A to Z", SortByAuthorName False )
                , ( "Author: Z to A", SortByAuthorName True )
                , ( "Date: Newest to Oldest", SortByReleaseDate False )
                , ( "Date: Oldest to Newest", SortByReleaseDate True )
                ]

        sortByOption : Int -> ( String, SortBy ) -> Html.Html Msg
        sortByOption idx ( sortText, sortValue ) =
            option [ Attr.selected (state.sortBy == sortValue), Attr.value <| String.fromInt idx ] [ text sortText ]
    in
    div [ class "menu" ]
        [ div [ class "menu__filters" ]
            [ label [ Attr.for "search" ]
                [ text "Search: "
                , input [ Attr.type_ "text", Attr.id "search", Attr.value state.search, Ev.onInput InputSearch ] []
                ]
            , label [ Attr.for "genre-filter" ]
                [ text "Genres: "
                , select [ Attr.id "genre-filter", Ev.onInput (String.toInt >> Maybe.withDefault 0 >> SelectedGenre) ]
                    (Collection.toList data.genres
                        |> List.map (\genre -> genreOption genre.id genre.title)
                        |> (::) (genreOption 0 "Any")
                    )
                ]
            , label [ Attr.for "sort-by" ]
                [ text "Sort By: "
                , select
                    [ Attr.id "sort-by"
                    , Ev.onInput
                        (String.toInt
                            >> Maybe.andThen (\idx -> Array.get idx sortByOptions)
                            >> Maybe.map Tuple.second
                            >> Maybe.withDefault (SortByTitle False)
                            >> SelectedSortBy
                        )
                    ]
                    (sortByOptions
                        |> Array.indexedMap sortByOption
                        |> Array.toList
                    )
                ]
            ]
        ]


sortBookBy : Data -> SortBy -> Book -> Book -> Order
sortBookBy data sortBy book1 book2 =
    let
        invertedOrder order =
            case order of
                LT ->
                    GT

                EQ ->
                    EQ

                GT ->
                    LT
    in
    case sortBy of
        SortByTitle inverted ->
            compare book1.title book2.title
                |> Utils.quif inverted invertedOrder identity

        SortByAuthorName inverted ->
            let
                getAuthorName book =
                    Collection.get book.author data.authors
                        |> Maybe.map .name
                        |> Maybe.withDefault ""
            in
            compare (getAuthorName book1) (getAuthorName book2)
                |> Utils.quif inverted invertedOrder identity

        SortByReleaseDate inverted ->
            Date.compare book1.releaseDate book2.releaseDate
                |> Utils.quif inverted identity invertedOrder


viewBookList : Model -> Html.Html Msg
viewBookList { state, data } =
    let
        search =
            String.toLower state.search

        filterBook : Book -> Bool
        filterBook book =
            let
                authorName =
                    Collection.get book.author data.authors
                        |> Maybe.map .name
                        |> Maybe.withDefault ""
            in
            (state.genreFilter == 0 || Set.member state.genreFilter book.genres)
                && String.contains search (String.toLower <| book.title ++ authorName)

        viewBook : Book -> Html.Html Msg
        viewBook book =
            let
                maybeAuthor =
                    Collection.get book.author data.authors

                bookGenres =
                    Set.toList book.genres
                        |> List.filterMap (\id -> Collection.get id data.genres)

                coverUrl =
                    if String.isEmpty book.coverUrl then
                        "//via.placeholder.com/120"

                    else
                        book.coverUrl
            in
            li [ class "book" ]
                [ div [ class "book__cover", style "background-image" ("url(" ++ coverUrl ++ ")") ] []
                , div [ class "book__info" ]
                    [ div [ class "book__title" ] [ text book.title ]
                    , ul [ class "book__genres" ]
                        (bookGenres
                            |> List.map (\genre -> a [ class "book__genre", Attr.href "" ] [ li [] [ text genre.title ] ])
                        )
                    , div [ class "book__author" ]
                        (case maybeAuthor of
                            Just author ->
                                [ text "By "
                                , a [ Attr.href "" ] [ text author.name ]
                                ]

                            Nothing ->
                                []
                        )
                    , div [ class "book__release-date" ]
                        [ text "Released in "
                        , i [] [ text <| Date.format "MMMM d, y" book.releaseDate ]
                        ]
                    ]
                ]
    in
    main_ []
        [ ul [ class "book-list" ]
            (data.books
                |> Collection.toList
                |> List.filter filterBook
                |> List.sortWith (sortBookBy data state.sortBy)
                |> List.map viewBook
            )
        ]
