with
erc721_collection as (
    select
        chain,
        collection_name,
        collection_slug,
        contract_address
    from {{source('footprint', 'nft_collection_info')}}
    where standard = 'ERC721'
),
eth as (
    select
    *
    ,'Ethereum' as chain
    from {{source('footprint', 'ethereum_token_transfers')}}
    {{incremental_timestamp_filter_realtime(time_field_name='block_timestamp')}}
),
bsc as (
    select
    *
     ,'BNB Chain' as chain
    from {{source('footprint', 'bsc_token_transfers')}}
    {{incremental_timestamp_filter_realtime(time_field_name='block_timestamp')}}
),
polygon as (
    select
    *
    ,'Polygon' as chain
    from {{source('footprint', 'polygon_token_transfers')}}
    {{incremental_timestamp_filter_realtime(time_field_name='block_timestamp')}}
),
union_transfers as (
    select * from eth
    union all
    select * from bsc
    union all
    select * from polygon
),
erc721_transfers as (
    select
        nft.collection_name,
        nft.collection_slug,
        ut.*
    from union_transfers ut
    inner join
    erc721_collection nft
    on ut.chain = nft.chain
    and ut.token_address = nft.contract_address
)
select * from erc721_transfers