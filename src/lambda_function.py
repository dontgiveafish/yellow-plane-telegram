import os
import json
import boto3
from botocore.vendored import requests

telegram_bot_token = os.environ['TELEGRAM_BOT_TOKEN']
teams_table_name = os.environ['TEAMS_TABLE_NAME']


def send_message(text, chat_id):
    url = "https://api.telegram.org/bot{}/sendMessage".format(telegram_bot_token)
    requests.get(url, params={'text': text, 'chat_id': chat_id})


def get_teams_table():
    return boto3.resource('dynamodb').Table(teams_table_name)


# teams

def find_team(alias):
    response = get_teams_table().get_item(Key={'alias': alias})
    if 'Item' in response:
        return response['Item']


def join_team(alias, member):
    team = find_team(alias)

    if not team:
        team = {
            'alias': alias,
            'members': [member],
            'owner': member,
        }

    if member not in team['members']:
        team['members'].append(member)

    get_teams_table().put_item(Item=team)
    return team


def leave_team(alias, member):
    team = find_team(alias)
    if not team:
        return

    if member in team['members']:
        team['members'].remove(member)
        get_teams_table().put_item(Item=team)


def list_teams(alias):
    response = get_teams_table().get_item(Key={'alias': alias})
    if not response:
        return []

    return response['Item']['members']


# commands

def execute_command(command_name, command_arguments):
    command_function = 'command_' + str(command_name)
    if command_function in globals():
        command_callable = globals()[command_function]
        if callable(command_callable):
            command_callable(*command_arguments)
            return True

    return False


def command_join(chat, team):
    join_team(team, chat)
    send_message('Welcome to {} team'.format(team), chat)


def command_leave(chat, team):
    leave_team(team, chat)
    send_message('You just left {} team'.format(team), chat)


# lambda handler

def lambda_handler(event, context):
    resource = event['resource'].lstrip('/')
    body = json.loads(event['body'])

    if resource == 'telegram_webhook':

        chat_id = body['message']['chat']['id']

        try:
            text = body['message']['text']
            parts = text.split(' ')

            command_name = parts[0].lstrip('/')
            command_arguments = [chat_id] + parts[1:]

            if not execute_command(command_name, command_arguments):
                send_message("Unknown command, please try harder.", chat_id)

        except BaseException as e:
            send_message("There was a problem performing your request. Please try again later.", chat_id)

    if resource == 'message_broadcast':
        team = find_team(body['team'])
        if team:
            for chat in team['members']:
                send_message(body['message'], chat)

    return {'statusCode': 200}
