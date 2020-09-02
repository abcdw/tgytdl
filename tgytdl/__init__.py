#!/usr/bin/env python
import logging
from aiogram import Bot, Dispatcher, executor, types
logging.basicConfig(level=logging.INFO)

import re
import subprocess


bot = Bot(token="1342030250:AAEXnVeXmaKIa7_BB2Rxs_0Q4Vs9BmStdt4")
dp = Dispatcher(bot)

yt_regexp = "(youtube.com/watch\?v=(\w*)|youtu.be/(\w*))"

@dp.message_handler(regexp='(youtube.com|youtu.be)')
async def echo(message: types.Message):
    url = re.search(yt_regexp, message.text).group(0)
    await message.answer("Downloading `{0}`".format(url), parse_mode = 'Markdown')
    vid = download_yt(url)
    with open(vid, 'rb') as video:
        await message.reply_video(video, caption='Video uploaded by tgytdl')
    #await message.reply(url)

@dp.message_handler(commands=["start"])
async def cmd_start(message: types.Message):
    await message.answer("Send a message with youtube link in it.")

test_url = "https://youtu.be/hAq443fhyDo"

def download_yt(url):
    cmd = "youtube-dl {0} --id --exec ls | tail -n 1".format(url)
    result = subprocess.check_output(cmd, shell=True)
    return result.rstrip()

def run_bot():
    executor.start_polling(dp, skip_updates=True)

if __name__ == "__main__":
    run_bot()
