import graphene

from graphene_django.types import DjangoObjectType

from app.models import IPAddress


class IPAddressType(DjangoObjectType):
    class Meta:
        model = IPAddress


class Query(graphene.ObjectType):
    all_ip_addresses = graphene.List(IPAddressType)
    # all_coins_by_symbol = graphene.List(CoinType, q=graphene.String())

    def resolve_all_ip_addresses(root, info, **kwargs):
        return IPAddress.objects.all()

    # def resolve_all_coins_by_symbol(root, info, **kwargs):
    #     search_string = kwargs.get("q")
    #     result = Coin.objects.filter(
    #         symbol__startswith=search_string,
    #     ).all()
    #     return result

class CreateIPAddressMutation(graphene.Mutation):
    class Arguments:
        name = graphene.String()
    Output = IPAddressType
    def mutate(root, info, **kwargs):
        name = kwargs["name"]
        return IPAddress.objects.create(ip_address=ip_address)


class Mutation(graphene.ObjectType):
    create_ip_address = CreateIPAddressMutation.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
