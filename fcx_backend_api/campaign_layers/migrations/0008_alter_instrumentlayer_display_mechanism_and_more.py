# Generated by Django 4.2.6 on 2023-11-01 14:50

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('campaign_layers', '0007_rename_field_campagin_name_instrumentlayer_field_campaign_name'),
    ]

    operations = [
        migrations.AlterField(
            model_name='instrumentlayer',
            name='display_mechanism',
            field=models.CharField(choices=[('czml', 'CZML'), ('3dtile', '3DTile Point Cloud'), ('wmts', 'Web Map Tile Server'), ('points', 'Point Primitive')], max_length=100),
        ),
        migrations.AlterField(
            model_name='instrumentlayer',
            name='layer_id',
            field=models.CharField(max_length=100, unique=True),
        ),
        migrations.AlterField(
            model_name='instrumentlayer',
            name='platform',
            field=models.CharField(choices=[('air', 'Air'), ('ground', 'Ground'), ('satellite', 'Satellite')], max_length=100),
        ),
        migrations.AlterField(
            model_name='instrumentlayer',
            name='type',
            field=models.CharField(choices=[('track', 'Navigation Track'), ('instrument', 'Sensor Instrument')], max_length=100),
        ),
    ]
