# Generated by Django 4.2.6 on 2023-10-27 16:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('campaign_layers', '0003_rename_doi_url_doi_url_alter_doi_campaign_layer_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='campaignlayer',
            name='description',
            field=models.TextField(),
        ),
        migrations.AlterField(
            model_name='campaignlayer',
            name='logo_url',
            field=models.URLField(max_length=2049),
        ),
        migrations.AlterField(
            model_name='doi',
            name='url',
            field=models.URLField(max_length=2049),
        ),
        migrations.AlterField(
            model_name='instrumentlayer',
            name='url',
            field=models.URLField(max_length=2049),
        ),
        migrations.AlterField(
            model_name='legend',
            name='url',
            field=models.URLField(max_length=2049),
        ),
        migrations.AlterField(
            model_name='link',
            name='url',
            field=models.URLField(max_length=2049),
        ),
    ]
