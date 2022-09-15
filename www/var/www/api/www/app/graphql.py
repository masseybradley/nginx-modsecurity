import graphene

from graphene_django.types import DjangoObjectType

from app.models import IPAddress


class IPAddressType(DjangoObjectType):
    class Meta:
        model = IPAddress


class Query(graphene.ObjectType):
    all_ip_addresses = graphene.List(IPAddressType)

    def resolve_all_ip_addresses(root, info, **kwargs):
        return IPAddress.objects.all()


class CreateIPAddressMutation(graphene.Mutation):
    class Arguments:
        ip_address = graphene.String()
    Output = IPAddressType
    def mutate(root, info, **kwargs):
        ip_address = kwargs["ip_address"]
        obj, created = IPAddress.objects.get_or_create(ip_address=ip_address)
        return obj


class Mutation(graphene.ObjectType):
    create_ip_address = CreateIPAddressMutation.Field()


schema = graphene.Schema(query=Query, mutation=Mutation)
