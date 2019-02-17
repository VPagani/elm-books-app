module Collection exposing (Collection, Id, decoder, empty, encode, exists, fromList, get, toList)

import Dict
import Json.Decode as Decode
import Json.Encode as Encode
import Set


type alias Id =
    Int


{-| A record with an Identifier
-}
type alias Document value =
    { value | id : Id }


type Collection value
    = Collection Id (Dict.Dict Id value)


empty : Collection value
empty =
    Collection 0 Dict.empty


toList : Collection (Document value) -> List (Document value)
toList (Collection _ dict) =
    Dict.values dict


listToDict : List (Document value) -> Dict.Dict Id (Document value)
listToDict =
    List.map (\doc -> ( doc.id, doc ))
        >> Dict.fromList


fromList : List (Document value) -> Collection (Document value)
fromList =
    listToDict
        >> (\dict ->
                Collection
                    (dict |> Dict.keys |> List.maximum |> Maybe.withDefault 0)
                    dict
           )


encode : (Document value -> Encode.Value) -> Collection (Document value) -> Encode.Value
encode docEncoder (Collection lastId dict) =
    Encode.object
        [ ( "lastId", Encode.int lastId )
        , ( "documents", Encode.list docEncoder (Dict.values dict) )
        ]


decoder : Decode.Decoder (Document value) -> Decode.Decoder (Collection (Document value))
decoder docDecoder =
    Decode.map2 Collection
        (Decode.field "lastId" Decode.int)
        (Decode.field "documents" (Decode.list docDecoder |> Decode.map listToDict))


insert : Document value -> Collection (Document value) -> Collection (Document value)
insert value (Collection lastId dict) =
    let
        id =
            lastId + 1

        valueWithId =
            { value | id = id }
    in
    Collection id (Dict.insert id value dict)


update : Document value -> Collection (Document value) -> Collection (Document value)
update doc (Collection lastId dict) =
    if Dict.member doc.id dict then
        Collection lastId (Dict.insert doc.id doc dict)

    else
        Collection lastId dict


delete : Document value -> Collection (Document value) -> Collection (Document value)
delete doc (Collection lastId dict) =
    Collection lastId (Dict.remove doc.id dict)


get : Id -> Collection (Document value) -> Maybe (Document value)
get id (Collection _ dict) =
    Dict.get id dict


getBy : (Document value -> a) -> a -> Collection (Document value) -> Maybe (Document value)
getBy prop value (Collection _ dict) =
    let
        check : Id -> Document value -> Bool
        check _ doc =
            prop doc == value
    in
    Dict.filter check dict
        |> Dict.values
        |> List.head


exists : Id -> Collection (Document value) -> Bool
exists id (Collection _ dict) =
    Dict.member id dict
